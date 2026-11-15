#!/bin/bash
# Final campaign on Istio 1.31.4 without ML-DSA (~36 h in total), runnable in parts:
#   s1 s2 s3 s4 : grid sessions, RATES x MRPCS (without 300:1, 400:1), 5 setups, 2 runs each
#                 (~8 h per session; 4 sessions = 8 runs)
#   f2a         : classic TLS 1.2 / 1.3, handshake per request (mrpc=1, 200 req/s), 8 runs (~2.3 h)
#   f2b         : classic TLS 1.2 / 1.3, keep-alive + 1 MB responses (100 req/s), 8 runs (~2.3 h)
# Every step starts on a fresh cluster with the session gate; every block is framed by entry
# and exit canaries (01_scripts/gate.sh), a block whose exit canary is off by more than 5% is
# measured again. Memory and CPU are recorded in every window.
# Each phase appends to its own fixed directory, so parts can run on different days.
# A step that was interrupted can simply be run again: finished blocks are skipped.
# Before every part: 01_scripts/windows/stabilize_windows.ps1 on Windows (turbo off), check calib_ms ~400 ms.
#
# Usage:
#   ./run_all_final.sh s1 2>&1 | tee -a run_all_final.log      # one part
#   ./run_all_final.sh s2 s3 2>&1 | tee -a run_all_final.log   # several parts in a row
#   ./run_all_final.sh 2>&1 | tee -a run_all_final.log         # everything (s1 s2 s3 s4 f2a f2b)
set -uo pipefail
cd "$(dirname "$0")"

R=04_results
MAIN_SETUPS="plaintext mtls1.3-x25519 mtls1.3-x25519-full mtls1.3-postquantum mtls1.3-postquantum-full"
CLASSIC_SETUPS="plaintext mtls1.3-default mtls1.2-gcm mtls1.2-gcm256 mtls1.2-chacha mtls1.2-cbc"
export SETTLE_S=20
# Client ticket slots for the resumed arms (mtls1.3-x25519, mtls1.3-postquantum, also the canary).
# R1 (04_results/R1_resumption_20261109_1931): with the Envoy default of 1 the resumed share falls
# to 0.85 at 400 req/s, mrpc=1; with 16 it is >= 0.998 everywhere, so the resumed arm is clean.
export MAX_SESSION_KEYS=16
# checked again before every block (run_sweeps.sh calib_guard), unless ALLOW_TURBO=1
[ "${ALLOW_TURBO:-0}" = 1 ] || export CALIB_MIN=300

# session S with up to 3 attempts (fresh cluster each time; finished blocks are skipped)
session() {
  local s=$1; shift
  for attempt in 1 2 3; do
    env "$@" START_SESSION="$s" SESSIONS=1 ./run_campaign.sh && return 0
    echo "!!! $(date '+%F %T') session $s attempt $attempt failed"
  done
  return 1
}

# Turbo check: with turbo off (stabilize_windows.ps1) calib_ms was 380-430 ms in F3, with turbo on
# 150-250 ms (pilot 2026-11-10, two machine states ~25% apart). Refuse to start with turbo on.
source ./01_scripts/lib_setups.sh
CALIB=$(for i in 1 2 3; do calib_ms; done | sort -g | sed -n 2p)
echo "=== $(date '+%F %T') calib_ms median of 3: $CALIB ms"
if [ "${ALLOW_TURBO:-0}" != 1 ] && awk -v c="$CALIB" 'BEGIN { exit !(c < 300) }'; then
  echo "calib_ms=$CALIB ms < 300 ms: turbo looks ON. Run 01_scripts/windows/stabilize_windows.ps1 first (or ALLOW_TURBO=1)."
  exit 1
fi

STEPS="${*:-s1 s2 s3 s4 f2a f2b}"
for STEP in $STEPS; do
  echo "=== $(date '+%F %T') STEP $STEP"
  case $STEP in
    s[1-4])
      session "${STEP#s}" OUT_DIR="$R/Final_grid" MODE=grid N_RUNS=2 \
        RATES="100 200 300 400" MRPCS="1 2 5 0" SETUPS="$MAIN_SETUPS" ;;
    fix)
      # re-measure the 4 blocks where the machine state flipped inside the block (PQ resumed arm
      # off by 5-43%); they replace the originals via 04_results/Final_grid/replacements.csv
      session 5 OUT_DIR="$R/Final_grid" MODE=grid N_RUNS=1 \
        RATES="300 400" MRPCS="2 5 0" ONLY="400:2 400:0 300:2 300:5" SETUPS="$MAIN_SETUPS" ;;
    f2a)
      session 11 OUT_DIR="$R/Final_F2a_classic_handshake" MODE=mrpc MRPCS=1 MRPC_RATE=200 \
        N_RUNS=8 SETUPS="$CLASSIC_SETUPS" ;;
    f2b)
      session 12 OUT_DIR="$R/Final_F2b_classic_payload" MODE=mrpc MRPCS=0 MRPC_RATE=100 \
        N_RUNS=8 SETUPS="$CLASSIC_SETUPS" \
        TARGET_URL=http://httpbin.default.svc.cluster.local:8000/bytes/1000000 ;;
    *) echo "Unknown step '$STEP' (use s1 s2 s3 s4 fix f2a f2b)"; exit 1 ;;
  esac || echo "!!! $(date '+%F %T') step $STEP failed twice"
  echo "=== $(date '+%F %T') STEP $STEP finished"
done
echo "=== $(date '+%F %T') DONE: $STEPS"
