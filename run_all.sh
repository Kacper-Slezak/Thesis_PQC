#!/bin/bash
# Full measurement campaign (~17 h):
#   phase 1  : mrpc x resumption x key exchange (5 setups, mrpc 1 2 5 10 0, 3 sessions x 5 runs)
#   phase 2a : classic TLS 1.2 / 1.3 comparison, handshake per request (mrpc=1)
#   phase 2b : classic TLS 1.2 / 1.3 comparison, keep-alive + 1 MB responses (symmetric ciphers)
# Each phase ends up in its own directory under 04_results/.
# Usage: ./run_all.sh 2>&1 | tee run_all.log
set -uo pipefail
cd "$(dirname "$0")"

R=04_results
STAMP=$(date +%Y%m%d_%H%M)
MAIN_SETUPS="plaintext mtls1.3-x25519 mtls1.3-x25519-full mtls1.3-postquantum mtls1.3-postquantum-full"
CLASSIC_SETUPS="plaintext mtls1.3-default mtls1.2-gcm mtls1.2-gcm256 mtls1.2-chacha mtls1.2-cbc"
export MODE=mrpc SETTLE_S=20

# Summary/ must be empty at the start of each phase: the scripts append to sweeps.csv and curve_evidence.csv
finish_phase() {
  mkdir -p "$R/$1"
  mv "$R"/Summary/* "$R/$1"/ 2>/dev/null || true
  echo "=== $(date '+%F %T') results saved in $R/$1"
}

mkdir -p "$R/Summary"
[ -n "$(ls -A "$R/Summary")" ] && finish_phase "Archive/before_$STAMP"

echo "=== $(date '+%F %T') PHASE 1: mrpc x resumption x key exchange"
for S in 1 2 3; do
  MRPCS="1 2 5 10 0" MRPC_RATE=200 N_RUNS=5 SETUPS="$MAIN_SETUPS" \
    START_SESSION=$S SESSIONS=1 ./run_campaign.sh || echo "!!! $(date '+%F %T') session $S failed, continuing"
done
finish_phase "F1_mrpc_$STAMP"

echo "=== $(date '+%F %T') PHASE 2a: classic TLS, handshake per request"
MRPCS="1" MRPC_RATE=200 N_RUNS=3 SETUPS="$CLASSIC_SETUPS" \
  START_SESSION=11 SESSIONS=1 ./run_campaign.sh || echo "!!! $(date '+%F %T') phase 2a failed, continuing"
finish_phase "F2a_classic_handshake_$STAMP"

echo "=== $(date '+%F %T') PHASE 2b: classic TLS, keep-alive + 1 MB responses"
MRPCS="0" MRPC_RATE=100 N_RUNS=3 SETUPS="$CLASSIC_SETUPS" \
  TARGET_URL=http://httpbin.default.svc.cluster.local:8000/bytes/1000000 \
  START_SESSION=12 SESSIONS=1 ./run_campaign.sh || echo "!!! $(date '+%F %T') phase 2b failed"
finish_phase "F2b_classic_payload_$STAMP"

echo "=== $(date '+%F %T') ALL DONE"