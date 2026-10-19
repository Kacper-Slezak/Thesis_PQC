#!/bin/bash
# Run benchmark campaign across multiple cluster sessions
#
# Usage:
#   ./run_campaign.sh                                   # 3 sessions x 10 runs
#   START_SESSION=4 SESSIONS=1 N_RUNS=10 ./run_campaign.sh
#   SESSIONS=1 N_RUNS=1 ./run_campaign.sh               # quick test run
set -eo pipefail
cd "$(dirname "$0")"

SESSIONS="${SESSIONS:-3}"            # number of cluster sessions
START_SESSION="${START_SESSION:-1}"  # starting session index
export N_RUNS="${N_RUNS:-10}"        # runs per session
export RATES="${RATES:-200}"         # requests per second
SETUPS="${SETUPS:-plaintext mtls1.3-x25519 mtls1.3-x25519-full mtls1.3-postquantum mtls1.3-postquantum-full}"
MODE="${MODE:-mrpc}"                  # handshake | mrpc

LAST=$(( START_SESSION + SESSIONS - 1 ))
for S in $(seq "$START_SESSION" "$LAST"); do
  echo "########## SESSION $S (of $START_SESSION..$LAST) ##########"
  export SESSION=$S

  ./01_scripts/setup_cluster.sh
  kubectl wait --for=condition=ready pod -l app=httpbin --timeout=180s
  kubectl wait --for=condition=ready pod -l app=k6 --timeout=180s
  if ! ./01_scripts/verify_ciphers.sh; then
    echo "verify_ciphers failed in session $S - stopping, nothing was measured" >&2
    exit 1
  fi
  ./01_scripts/quiet_mode.sh on                       # disable monitoring during measurements

    ./run_sweeps.sh "$MODE" $SETUPS
done

# Run statistical analysis on sweep results
python ./05_analytics/analyze_stats.py "$MODE" \  
  || echo "Warning: analyze_stats.py failed (is .venv set up?)"


echo "Done. Results: 04_results/Summary/sweeps.csv, report: 04_results/Summary/stats_report.md"
