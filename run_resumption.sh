#!/bin/bash
# R1: why is resumption incomplete under concurrency? (vault: Inzynierka_Kampania_koncowa_plan.md, section 5)
# Hypothesis H-R1: the client keeps only max_session_keys tickets (Envoy default 1) and TLS 1.3
# tickets are single-use, so connections that start before the next ticket arrives do a full
# handshake. Prediction: resumed share = session_reused / (2 * handshakes) grows towards 1 with
# a larger max_session_keys, most at 300-400 req/s.
#
# Sweep: max_session_keys x rate x mrpc, arm mtls1.3-postquantum, no stability gate.
# Each (repetition, max_session_keys) is its own SESSION label, values shuffled per repetition,
# so time drift is not aligned with max_session_keys. About 2.7 h with the defaults.
# Usage: ./run_resumption.sh 2>&1 | tee run_resumption.log
set -uo pipefail
cd "$(dirname "$0")"

R=04_results
STAMP=$(date +%Y%m%d_%H%M)
KEYS="${KEYS:-1 4 16 64}"            # 1 = Envoy default
REPS="${REPS:-3}"
export RATES="${RATES:-100 300 400}" MRPCS="${MRPCS:-1 2}" EXCLUDE="" GATE=0 SETTLE_S=20 N_RUNS=1

mkdir -p "$R/Summary"
if [ -n "$(ls -A "$R/Summary")" ]; then
  mkdir -p "$R/Archive/before_$STAMP" && mv "$R"/Summary/* "$R/Archive/before_$STAMP"/
fi

for REP in $(seq 1 "$REPS"); do
  for K in $(printf "%s\n" $KEYS | shuf); do
    echo "=== $(date '+%F %T') R1 rep=$REP max_session_keys=$K"
    MAX_SESSION_KEYS=$K SESSION="msk${K}_rep${REP}" ./run_sweeps.sh grid mtls1.3-postquantum \
      || echo "!!! $(date '+%F %T') rep=$REP keys=$K failed, continuing"
  done
done

OUT="$R/R1_resumption_$STAMP"
mkdir -p "$OUT" && mv "$R"/Summary/* "$OUT"/
echo "=== $(date '+%F %T') results saved in $OUT"
# resumed share per (max_session_keys, rate, mrpc)
awk -F, 'NR == 1 { for (i = 1; i <= NF; i++) c[$i] = i; next }
  { k = $c["max_session_keys"] " " $c["rate_target"] " " $c["mrpc"]
    hs[k] += $c["handshakes"]; ru[k] += $c["session_reused"] }
  END { print "max_session_keys rate mrpc resumed_share"
        for (k in hs) printf "%s %.3f\n", k, (hs[k] ? ru[k] / (2 * hs[k]) : 0) }' "$OUT/sweeps.csv" | sort -k1,1n -k2,2n -k3,3n
