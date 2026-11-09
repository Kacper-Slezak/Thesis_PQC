#!/bin/bash
# Final campaign on Istio 1.31.4 without ML-DSA (~42 h):
#   grid : RATES x MRPCS (without 300:1, 400:1), 5 setups, 4 sessions x 2 runs = 8 runs (~34 h)
#   F2a  : classic TLS 1.2 / 1.3, handshake per request (mrpc=1, 200 req/s), 8 runs (~2.3 h)
#   F2b  : classic TLS 1.2 / 1.3, keep-alive + 1 MB responses (100 req/s), 8 runs (~2.3 h)
# Every session starts on a fresh cluster with the session gate; every block is framed by the
# +-5% stability gate (01_scripts/gate.sh). Memory and CPU are recorded in every window.
# A failed session is restarted once on a fresh cluster; finished blocks are skipped.
# Usage: ./run_all_final.sh 2>&1 | tee run_all_final.log
set -uo pipefail
cd "$(dirname "$0")"

R=04_results
STAMP=$(date +%Y%m%d_%H%M)
MAIN_SETUPS="plaintext mtls1.3-x25519 mtls1.3-x25519-full mtls1.3-postquantum mtls1.3-postquantum-full"
CLASSIC_SETUPS="plaintext mtls1.3-default mtls1.2-gcm mtls1.2-gcm256 mtls1.2-chacha mtls1.2-cbc"
export SETTLE_S=20
# Client ticket slots for the resumed arms (mtls1.3-x25519, mtls1.3-postquantum, also the canary).
# R1 (04_results/R1_resumption_20261109_1931): with the Envoy default of 1 the resumed share falls
# to 0.85 at 400 req/s, mrpc=1; with 16 it is >= 0.998 everywhere, so the resumed arm is clean.
export MAX_SESSION_KEYS=16

# Summary/ must be empty at the start of each phase: the scripts append to its CSV files
finish_phase() {
  mkdir -p "$R/$1"
  mv "$R"/Summary/* "$R/$1"/ 2>/dev/null || true
  echo "=== $(date '+%F %T') results saved in $R/$1"
}

# session S with up to 2 attempts (fresh cluster each time)
session() {
  local s=$1; shift
  for attempt in 1 2; do
    env "$@" START_SESSION="$s" SESSIONS=1 ./run_campaign.sh && return 0
    echo "!!! $(date '+%F %T') session $s attempt $attempt failed"
  done
  return 1
}

mkdir -p "$R/Summary"
[ -n "$(ls -A "$R/Summary")" ] && finish_phase "Archive/before_$STAMP"

echo "=== $(date '+%F %T') GRID: 4 sessions x 2 runs"
for S in 1 2 3 4; do
  session "$S" MODE=grid N_RUNS=2 RATES="100 200 300 400" MRPCS="1 2 5 0" SETUPS="$MAIN_SETUPS" \
    || echo "!!! $(date '+%F %T') session $S failed twice, continuing"
done
finish_phase "Final_grid_$STAMP"

echo "=== $(date '+%F %T') F2a: classic TLS, handshake per request"
session 11 MODE=mrpc MRPCS=1 MRPC_RATE=200 N_RUNS=8 SETUPS="$CLASSIC_SETUPS" \
  || echo "!!! $(date '+%F %T') F2a failed, continuing"
finish_phase "Final_F2a_classic_handshake_$STAMP"

echo "=== $(date '+%F %T') F2b: classic TLS, keep-alive + 1 MB responses"
session 12 MODE=mrpc MRPCS=0 MRPC_RATE=100 N_RUNS=8 SETUPS="$CLASSIC_SETUPS" \
  TARGET_URL=http://httpbin.default.svc.cluster.local:8000/bytes/1000000 \
  || echo "!!! $(date '+%F %T') F2b failed"
finish_phase "Final_F2b_classic_payload_$STAMP"

echo "=== $(date '+%F %T') ALL DONE"
