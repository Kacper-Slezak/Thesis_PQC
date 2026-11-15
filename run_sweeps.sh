#!/bin/bash
# Run benchmark sweeps and append results to sweeps.csv
#
# Usage:
#   ./run_sweeps.sh handshake [setups...]
#   ./run_sweeps.sh grid      [setups...]   # every RATES x MRPCS point, all setups back to back
#   ./run_sweeps.sh mrpc      [setups...]   # MRPC_RATE x every MRPCS value
#
# Every mode measures in blocks: block = one (rate, mrpc) point with all setups in random
# order, framed by the stability gate (01_scripts/gate.sh; GATE=0 turns it off). A block whose
# exit canary is off is kept in the CSV as block_status=rejected and measured again.
# Finished blocks go to $OUT/done_blocks.txt, so a restarted script skips them.
#
# Example:
#   N_RUNS=10 RATES="200" ./run_sweeps.sh handshake plaintext mtls1.3-x25519 mtls1.3-x25519-full mtls1.3-postquantum-full
set -eo pipefail
cd "$(dirname "$0")"
source ./01_scripts/lib_setups.sh

N_RUNS="${N_RUNS:-3}"              # runs per setup
DURATION="${DURATION:-60}"         # test duration [s]
WARM_S="${WARM_S:-10}"             # warmup time [s]
COOL_S="${COOL_S:-5}"              # cooldown time [s]
COOLDOWN_S="${COOLDOWN_S:-10}"     # pause between test points [s]
SETTLE_S="${SETTLE_S:-60}"         # wait time after config change [s]
RATES="${RATES:-100 200 300}"      # handshake mode: rates [req/s]
MRPCS="${MRPCS:-1 2 5 10 50 0}"    # mrpc mode: req per connection (0 = unlimited)
MRPC_RATE="${MRPC_RATE:-200}"      # mrpc mode: target rate [req/s]
SESSION="${SESSION:-1}"            # session ID
BLOCK_RETRIES="${BLOCK_RETRIES:-2}" # extra attempts for a block rejected by the exit gate
EXCLUDE="${EXCLUDE-300:1 400:1}"   # grid mode: rate:mrpc points to skip (overloaded in F3)
ONLY="${ONLY:-}"                   # grid mode: measure only these rate:mrpc points (re-measured blocks)
CALIB_MIN="${CALIB_MIN:-0}"        # before each block wait while calib_ms < this [ms] (turbo back on); 0 = off
CALIB_WAIT_MAX_S="${CALIB_WAIT_MAX_S:-7200}"  # give up (exit 1) after waiting this long [s]

STEADY_S=$(( DURATION - WARM_S - COOL_S ))   # measurement window duration
K6_SCRIPT=./03_test_scripts/main_k6_scenarios.js
OUT="${OUT_DIR:-./04_results/Summary}"   # results directory (CSV files are appended)
CSV=$OUT/sweeps.csv
DONE=$OUT/done_blocks.txt
ROWS=$OUT/.block_rows.tmp

MODE=$1; shift || true
if [ "$MODE" != "handshake" ] && [ "$MODE" != "mrpc" ] && [ "$MODE" != "grid" ]; then
  echo "Usage: $0 handshake|mrpc|grid [setup ...]"; exit 1
fi
if [ "$#" -gt 0 ]; then SETUPS=("$@"); else SETUPS=("${ALL_SETUPS[@]}"); fi

K6_POD=$(kubectl get pods -l app=k6 -o jsonpath='{.items[0].metadata.name}')
HTTPBIN_POD=$(kubectl get pods -l app=httpbin -o jsonpath='{.items[0].metadata.name}')
mkdir -p "$OUT"
source ./01_scripts/gate.sh
ISTIO_VER=$(kubectl get deploy istiod -n istio-system -o jsonpath='{.spec.template.spec.containers[0].image}' | sed 's/.*://')
./01_scripts/record_env.sh "$OUT/environment_sweeps_$(date +%Y%m%d_%H%M%S).txt" || true
trap cleanup_mesh_config EXIT

# CSV header
if [ ! -f "$CSV" ]; then
  echo "mode,setup,rate_target,mrpc,fraction,run,window_rps,k6_rps,p50_ms,p95_ms,p99_ms,fail_rate,dropped_iters,client_sidecar_cpu,server_sidecar_cpu,handshakes,handshakes_per_s,session_reused,conn_errors,cpu_per_req_us,cpu_per_handshake_us,netem_rtt_ms,netem_loss_pct,cert_key,timestamp,session,calib_ms,$MEM_COLS,max_session_keys,istio_version,block_id,gate_entry,block_status,gate_entry_dev_pct,gate_exit_dev_pct" > "$CSV"
fi

# Warmup traffic after config change
warmup() {
  kubectl exec -i "$K6_POD" -c k6 -- k6 run -e TEST_TYPE=handshake -e RATE=50 -e DURATION=20s - \
    < "$K6_SCRIPT" > /dev/null 2>&1 || true
  sleep "$SETTLE_S"
}

# Run one measurement point
one_point() {
  local setup=$1 rate=$2 mrpc=$3 run=$4 block=$5
  echo "--- [$MODE] $setup rate=$rate mrpc=$mrpc run=$run block=$block ---"
  local calib
  calib=$(calib_ms)

  measure_window "$K6_POD" "$HTTPBIN_POD" "$WARM_S" "$STEADY_S" "$K6_SCRIPT" \
    -e TEST_TYPE=handshake -e RATE="$rate" -e DURATION="${DURATION}s" \
    ${TARGET_URL:+-e "TARGET_URL=$TARGET_URL"}
  record_evidence "$setup" "${MODE}_$block"

  local summary
  summary=$(kubectl exec "$K6_POD" -c k6 -- cat /tmp/summary.json 2>/dev/null || echo '{"metrics":{}}')
  local k6_rps p50 p95 p99 fail dropped
  k6_rps=$(echo "$summary"  | jq -r '.metrics.http_reqs.values.rate // ""')
  p50=$(echo "$summary"     | jq -r '.metrics.http_req_duration.values.med // ""')
  p95=$(echo "$summary"     | jq -r '.metrics.http_req_duration.values["p(95)"] // ""')
  p99=$(echo "$summary"     | jq -r '.metrics.http_req_duration.values["p(99)"] // ""')
  fail=$(echo "$summary"    | jq -r '.metrics.http_req_failed.values.rate // 0')
  dropped=$(echo "$summary" | jq -r '.metrics.dropped_iterations.values.count // 0')

  echo "$MODE,$setup,$rate,$mrpc,0,$run,$W_RPS,$k6_rps,$p50,$p95,$p99,$fail,$dropped,$W_CLIENT_CPU,$W_SERVER_CPU,$W_HS,$W_HS_PER_S,$W_REUSED,$W_ERRORS,$W_CPU_PER_REQ_US,$W_CPU_PER_HS_US,0,0,$(cert_key),$(date -u +%FT%TZ),$SESSION,$calib,$W_MEM,${MAX_SESSION_KEYS:-},$ISTIO_VER,$block" >> "$ROWS"
  echo "    rps=$W_RPS p99=$p99 cpu/req=${W_CPU_PER_REQ_US}us hs/s=$W_HS_PER_S reused=$W_REUSED errors=$W_ERRORS  calib=${calib}ms"
  if [ "$setup" = "plaintext" ] && [ "$W_HS" -gt 0 ]; then
    echo "WARNING: plaintext window had $W_HS TLS handshakes - traffic was not plaintext"
  fi

  sleep "$COOLDOWN_S"
}

# Points (rate:mrpc) measured as blocks in this mode
combos() {
  local r m
  case $MODE in
    grid)      for r in $RATES; do for m in $MRPCS; do
                 case " $EXCLUDE " in *" $r:$m "*) continue ;; esac
                 [ -z "$ONLY" ] || case " $ONLY " in *" $r:$m "*) ;; *) continue ;; esac
                 echo "$r:$m"
               done; done ;;
    mrpc)      for m in $MRPCS; do echo "$MRPC_RATE:$m"; done ;;
    handshake) for r in $RATES; do echo "$r:1"; done ;;
  esac
}

# Turbo guard: Windows can switch turbo back on mid-session (s3, 2026-11-12: calib ~166 ms
# for the whole session although 383 ms at start). Wait before a block until calib_ms is back.
calib_guard() {
  [ "$CALIB_MIN" != 0 ] || return 0
  local start=$SECONDS c
  while :; do
    c=$(for i in 1 2 3; do calib_ms; done | sort -g | sed -n 2p)
    awk -v c="$c" -v m="$CALIB_MIN" 'BEGIN { exit !(c >= m) }' && return 0
    if [ $(( SECONDS - start )) -ge "$CALIB_WAIT_MAX_S" ]; then
      echo "!!! calib_ms=$c ms < $CALIB_MIN ms for ${CALIB_WAIT_MAX_S}s: turbo still on, stopping" >&2
      exit 1
    fi
    echo "!!! $(date '+%F %T') calib_ms=$c ms < $CALIB_MIN ms: turbo looks ON, run 01_scripts/windows/stabilize_windows.ps1; waiting"
    sleep 60
  done
}

# One block: entry gate, all setups in random order, exit gate; repeated when rejected
run_block() {
  local run=$1 combo=$2 rate=${2%%:*} mrpc=${2##*:} prefix attempt status
  prefix="s${SESSION}_run${run}_r${rate}_m${mrpc}"
  # continue the attempt count of blocks rejected before a restart
  attempt=$( { grep -o "${prefix}_a[0-9]*" "$CSV" || true; } | sort -u | wc -l)
  while :; do
    attempt=$(( attempt + 1 ))
    local block="${prefix}_a${attempt}" setup
    calib_guard
    echo "=== block $block ($(date '+%F %T')) ==="
    gate_enter "$run" "$block" "$combo" "$rate" "$mrpc"
    : > "$ROWS"
    CANARY_APPLIED=""
    for setup in $(printf "%s\n" "${SETUPS[@]}" | shuf); do
      apply_setup "$setup"
      apply_dr "$setup" "$mrpc"
      warmup
      one_point "$setup" "$rate" "$mrpc" "$run" "$block"
    done
    CANARY_APPLIED=""
    gate_exit "$run" "$block" "$rate" "$mrpc"
    if   [ "$GATE" != 1 ];             then status=nogate
    elif [ "$GATE_EXIT" = pass ];      then status=ok
    elif [ "$attempt" -le "$BLOCK_RETRIES" ]; then status=rejected
    else status=exit_fail
    fi
    sed "s/\$/,$GATE_ENTRY,$status,$GATE_ENTRY_DEV,$GATE_EXIT_DEV/" "$ROWS" >> "$CSV"
    rm -f "$ROWS"
    echo "    block $block: entry=$GATE_ENTRY (${GATE_ENTRY_DEV}%) exit=$GATE_EXIT (${GATE_EXIT_DEV}%) -> $status"
    [ "$status" = rejected ] || break
  done
  echo "$MODE,$SESSION,$run,$combo" >> "$DONE"
}

gate_session
for RUN in $(seq 1 "$N_RUNS"); do
  for COMBO in $(combos | shuf); do
    if grep -qx "$MODE,$SESSION,$RUN,$COMBO" "$DONE" 2>/dev/null; then
      echo "skip finished block: session $SESSION run $RUN $COMBO"; continue
    fi
    run_block "$RUN" "$COMBO"
  done
done

echo "Done. Results appended to $CSV"
