#!/bin/bash
# Machine stability gate (+-GATE_PCT %), measured under load with a canary setup.
# Plan: vault note Inzynierka_Kampania_koncowa_plan.md, section 3.
#
#   gate_session  : once per session - warm up under load, then GATE_SESSION_N canary windows
#                   must all lie within +-GATE_PCT of their median and have CV <= GATE_CV_PCT
#   gate_enter    : canary before a block, within +-GATE_PCT of the reference for this
#                   (rate, mrpc) in this session (median of accepted entry canaries)
#   gate_exit     : canary after a block, within +-GATE_PCT of the entry canary
# Waiting is bounded (GATE_SESSION_MAX_S, GATE_BLOCK_MAX_S); after that the run goes on and
# the block is flagged, so a 2-day campaign never stalls.
#
# Sourced by run_sweeps.sh after lib_setups.sh. Needs: K6_POD, HTTPBIN_POD, K6_SCRIPT, WARM_S,
# STEADY_S, DURATION, SESSION, OUT, warmup(), optional TARGET_URL.

GATE="${GATE:-1}"                                  # 0 = no gate at all
GATE_PCT="${GATE_PCT:-5}"                          # allowed deviation [%]
GATE_CV_PCT="${GATE_CV_PCT:-3}"                    # session gate: max coefficient of variation [%]
GATE_WAIT_S="${GATE_WAIT_S:-120}"                  # pause before measuring again [s]
GATE_BLOCK_MAX_S="${GATE_BLOCK_MAX_S:-1800}"       # block entry: give up after [s]
GATE_SESSION="${GATE_SESSION:-1}"                  # 0 = skip the session gate
GATE_SESSION_WARM_S="${GATE_SESSION_WARM_S:-600}"  # session gate: warm-up under load [s]
GATE_SESSION_N="${GATE_SESSION_N:-5}"              # session gate: canary windows per try
GATE_SESSION_MAX_S="${GATE_SESSION_MAX_S:-3600}"   # session gate: give up after [s]
GATE_SESSION_RATE="${GATE_SESSION_RATE:-200}"      # session gate load [req/s]
GATE_SESSION_MRPC="${GATE_SESSION_MRPC:-1}"        # session gate requests per connection
CANARY="${CANARY:-mtls1.3-x25519}"                 # reference setup measured by the gate

GATE_CSV=$OUT/gate.csv          # every canary window
GATE_REF=$OUT/gate_ref.csv      # accepted entry canaries: session,combo,cpu_per_req_us
CANARY_APPLIED=""               # "setup|mrpc" currently applied; reset when anything else is applied

if [ ! -f "$GATE_CSV" ]; then
  echo "timestamp,session,run,block_id,phase,try,rate,mrpc,cpu_per_req_us,window_rps,ref_us,dev_pct,dev_global_pct,result,calib_ms" > "$GATE_CSV"
fi

# Deviation of $1 from $2 [%]
dev_pct() { awk -v a="$1" -v b="$2" 'BEGIN { if (b + 0 == 0) print "nan"; else printf "%.2f", (a - b) / b * 100 }'; }
# Exit status 0 when |$1| <= $2 (fails for nan)
within() { awk -v d="$1" -v l="$2" 'BEGIN { exit !(d != "nan" && d + 0 <= l && d + 0 >= -l) }'; }
# Median of numbers on stdin (prints nothing for empty input)
median() { sort -g | awk '{ v[NR] = $1 } END { if (NR) print (NR % 2) ? v[(NR + 1) / 2] : (v[NR / 2] + v[NR / 2 + 1]) / 2 }'; }
# Median of accepted entry canaries for a combo, in this session ($2 = session) or in all sessions ($2 empty)
gate_ref() {
  [ -f "$GATE_REF" ] || return 0
  awk -F, -v c="$1" -v s="$2" '$2 == c && (s == "" || $1 == s) { print $3 }' "$GATE_REF" | median
}

gate_log() {  # run block_id phase try rate mrpc ref dev dev_global result calib
  echo "$(date -u +%FT%TZ),$SESSION,$1,$2,$3,$4,$5,$6,$CANARY_US,$W_RPS,$7,$8,$9,${10},${11}" >> "$GATE_CSV"
}

# One canary window at (rate, mrpc); sets CANARY_US [us of sidecar CPU per request]
canary_window() {
  local rate=$1 mrpc=$2 warm=${3:-1}
  if [ "$CANARY_APPLIED" != "$CANARY|$mrpc" ]; then
    apply_setup "$CANARY"
    apply_dr "$CANARY" "$mrpc"
    CANARY_APPLIED="$CANARY|$mrpc"
  fi
  [ "$warm" = 1 ] && warmup
  CANARY_CALIB=$(calib_ms)
  measure_window "$K6_POD" "$HTTPBIN_POD" "$WARM_S" "$STEADY_S" "$K6_SCRIPT" \
    -e TEST_TYPE=handshake -e RATE="$rate" -e DURATION="${DURATION}s" \
    ${TARGET_URL:+-e "TARGET_URL=$TARGET_URL"}
  CANARY_US=$W_CPU_PER_REQ_US
  echo "    canary $CANARY rate=$rate mrpc=$mrpc cpu/req=${CANARY_US}us rps=$W_RPS calib=${CANARY_CALIB}ms"
}

gate_session() {
  [ "$GATE" = 1 ] && [ "$GATE_SESSION" = 1 ] || return 0
  local rate=$GATE_SESSION_RATE mrpc=$GATE_SESSION_MRPC start=$SECONDS try=0
  echo "=== session gate: ${GATE_SESSION_WARM_S}s warm-up at $rate req/s, then $GATE_SESSION_N canaries"
  apply_setup "$CANARY"
  apply_dr "$CANARY" "$mrpc"
  CANARY_APPLIED="$CANARY|$mrpc"
  kubectl exec -i "$K6_POD" -c k6 -- k6 run -e TEST_TYPE=handshake -e RATE="$rate" \
    -e DURATION="${GATE_SESSION_WARM_S}s" ${TARGET_URL:+-e "TARGET_URL=$TARGET_URL"} - \
    < "$K6_SCRIPT" > /dev/null 2>&1 || true
  while :; do
    try=$(( try + 1 ))
    local vals="" i
    for i in $(seq 1 "$GATE_SESSION_N"); do
      canary_window "$rate" "$mrpc" 0
      vals+="$CANARY_US"$'\n'
      gate_log 0 session session "$try.$i" "$rate" "$mrpc" "" "" "" sample "$CANARY_CALIB"
    done
    local med verdict
    med=$(printf "%s" "$vals" | median)
    verdict=$(printf "%s" "$vals" | awk -v m="$med" -v p="$GATE_PCT" -v cvmax="$GATE_CV_PCT" '
      { n++; s += $1; ss += $1 * $1; d = ($1 - m) / m * 100; if (d > p || d < -p || $1 + 0 == 0) bad++ }
      END { mean = s / n; sd = sqrt((ss - n * mean * mean) / (n - 1)); cv = sd / mean * 100
            printf "%s cv=%.2f", (bad || cv > cvmax) ? "fail" : "pass", cv }')
    echo "    session gate try $try: median=${med}us $verdict"
    CANARY_US=$med W_RPS=""
    if [ "${verdict%% *}" = pass ]; then
      gate_log 0 session session "$try" "$rate" "$mrpc" "$med" "" "" "pass ${verdict#* }" ""; return 0
    fi
    if [ $(( SECONDS - start )) -ge "$GATE_SESSION_MAX_S" ]; then
      gate_log 0 session session "$try" "$rate" "$mrpc" "$med" "" "" "timeout ${verdict#* }" ""
      echo "WARNING: session gate timed out, starting anyway"; return 0
    fi
    gate_log 0 session session "$try" "$rate" "$mrpc" "$med" "" "" "wait ${verdict#* }" ""
    sleep "$GATE_WAIT_S"
  done
}

# Sets GATE_ENTRY (off|first|ok|timeout), GATE_ENTRY_DEV, GATE_ENTRY_US
gate_enter() {
  local run=$1 block=$2 combo=$3 rate=$4 mrpc=$5
  GATE_ENTRY=off GATE_ENTRY_DEV="" GATE_ENTRY_US=""
  [ "$GATE" = 1 ] || return 0
  local ref glob dev dg start=$SECONDS try=0
  ref=$(gate_ref "$combo" "$SESSION")
  glob=$(gate_ref "$combo" "")
  while :; do
    try=$(( try + 1 ))
    canary_window "$rate" "$mrpc"
    dg=""; [ -n "$glob" ] && dg=$(dev_pct "$CANARY_US" "$glob")
    if [ -z "$ref" ]; then
      GATE_ENTRY=first; dev=0.00
    else
      dev=$(dev_pct "$CANARY_US" "$ref")
      if within "$dev" "$GATE_PCT"; then GATE_ENTRY=ok
      elif [ $(( SECONDS - start )) -ge "$GATE_BLOCK_MAX_S" ]; then GATE_ENTRY=timeout
      else
        gate_log "$run" "$block" enter "$try" "$rate" "$mrpc" "$ref" "$dev" "$dg" wait "$CANARY_CALIB"
        echo "    gate: canary ${dev}% from reference, waiting ${GATE_WAIT_S}s"
        sleep "$GATE_WAIT_S"; continue
      fi
    fi
    break
  done
  gate_log "$run" "$block" enter "$try" "$rate" "$mrpc" "$ref" "$dev" "$dg" "$GATE_ENTRY" "$CANARY_CALIB"
  GATE_ENTRY_DEV=$dev GATE_ENTRY_US=$CANARY_US
  if [ "$GATE_ENTRY" = first ] || [ "$GATE_ENTRY" = ok ]; then
    echo "$SESSION,$combo,$CANARY_US" >> "$GATE_REF"
  fi
}

# Sets GATE_EXIT (off|pass|fail) and GATE_EXIT_DEV (deviation from the entry canary)
gate_exit() {
  local run=$1 block=$2 rate=$3 mrpc=$4
  GATE_EXIT=off GATE_EXIT_DEV=""
  [ "$GATE" = 1 ] || return 0
  canary_window "$rate" "$mrpc"
  GATE_EXIT_DEV=$(dev_pct "$CANARY_US" "$GATE_ENTRY_US")
  if within "$GATE_EXIT_DEV" "$GATE_PCT"; then GATE_EXIT=pass; else GATE_EXIT=fail; fi
  gate_log "$run" "$block" exit 1 "$rate" "$mrpc" "$GATE_ENTRY_US" "$GATE_EXIT_DEV" "" "$GATE_EXIT" "$CANARY_CALIB"
}
