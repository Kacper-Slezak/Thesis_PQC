#!/bin/bash
# Campaign F3 (~20 h): offered load (RPS) x requests per connection (mrpc), 5 setups.
#   - for every (RPS, mrpc) point the 5 setups are measured back to back (same machine state)
#   - a calibration benchmark is recorded before every window (column calib_ms)
#   - figures are generated at the end (05_analytics/plot_results.py)
# Shorter variant (~15 h): MRPCS="1 5 0" ./run_all_grid.sh
# Usage: ./run_all_grid.sh 2>&1 | tee run_all_grid.log
set -uo pipefail
cd "$(dirname "$0")"

R=04_results
STAMP=$(date +%Y%m%d_%H%M)
export MODE=grid SETTLE_S=20 N_RUNS="${N_RUNS:-2}"
export RATES="${RATES:-100 200 300 400}" MRPCS="${MRPCS:-1 2 5 0}"
export SETUPS="plaintext mtls1.3-x25519 mtls1.3-x25519-full mtls1.3-postquantum mtls1.3-postquantum-full"

mkdir -p "$R/Summary"
if [ -n "$(ls -A "$R/Summary")" ]; then
  mkdir -p "$R/Archive/before_$STAMP" && mv "$R"/Summary/* "$R/Archive/before_$STAMP"/
fi

echo "=== $(date '+%F %T') F3 grid: RATES=[$RATES] MRPCS=[$MRPCS] N_RUNS=$N_RUNS"
for S in 1 2 3; do
  START_SESSION=$S SESSIONS=1 ./run_campaign.sh || echo "!!! $(date '+%F %T') session $S failed, continuing"
done

OUT="$R/F3_grid_$STAMP"
mkdir -p "$OUT" && mv "$R"/Summary/* "$OUT"/
echo "=== $(date '+%F %T') results saved in $OUT"
python3 ./05_analytics/plot_results.py "$OUT" || echo "Warning: plotting failed"
echo "=== $(date '+%F %T') ALL DONE"
