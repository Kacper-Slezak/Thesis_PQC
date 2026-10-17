#!/bin/bash
# Run benchmark sweeps and append results to sweeps.csv
#
# Usage:
#   ./run_sweeps.sh handshake [setups...]
#   ./run_sweeps.sh mrpc      [setups...]
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

STEADY_S=$(( DURATION - WARM_S - COOL_S ))   # measurement window duration
K6_SCRIPT=./03_test_scripts/main_k6_scenarios.js
OUT=./04_results/Summary
CSV=$OUT/sweeps.csv

MODE=$1; shift || true
if [ "$MODE" != "handshake" ] && [ "$MODE" != "mrpc" ]; then
  echo "Usage: $0 handshake|mrpc [setup ...]"; exit 1
fi
if [ "$#" -gt 0 ]; then SETUPS=("$@"); else SETUPS=("${ALL_SETUPS[@]}"); fi

K6_POD=$(kubectl get pods -l app=k6 -o jsonpath='{.items[0].metadata.name}')
HTTPBIN_POD=$(kubectl get pods -l app=httpbin -o jsonpath='{.items[0].metadata.name}')
mkdir -p "$OUT"
./01_scripts/record_env.sh "$OUT/environment_sweeps_$(date +%Y%m%d_%H%M%S).txt" || true
trap cleanup_mesh_config EXIT

# CSV header
if [ ! -f "$CSV" ]; then
  echo "mode,setup,rate_target,mrpc,fraction,run,window_rps,k6_rps,p50_ms,p95_ms,p99_ms,fail_rate,dropped_iters,client_sidecar_cpu,server_sidecar_cpu,handshakes,handshakes_per_s,session_reused,conn_errors,cpu_per_req_us,cpu_per_handshake_us,netem_rtt_ms,netem_loss_pct,cert_key,timestamp,session" > "$CSV"
fi

# Warmup traffic after config change
warmup() {
  kubectl exec -i "$K6_POD" -c k6 -- k6 run -e TEST_TYPE=handshake -e RATE=50 -e DURATION=20s - \
    < "$K6_SCRIPT" > /dev/null 2>&1 || true
  sleep "$SETTLE_S"
}

# Run one measurement point
one_point() {
  local setup=$1 rate=$2 mrpc=$3 run=$4
  echo "--- [$MODE] $setup rate=$rate mrpc=$mrpc run=$run ---"

  measure_window "$K6_POD" "$HTTPBIN_POD" "$WARM_S" "$STEADY_S" "$K6_SCRIPT" \
    -e TEST_TYPE=handshake -e RATE="$rate" -e DURATION="${DURATION}s"
  record_evidence "$setup" "${MODE}_r${rate}_m${mrpc}_run${run}"

  local summary
  summary=$(kubectl exec "$K6_POD" -c k6 -- cat /tmp/summary.json 2>/dev/null || echo '{"metrics":{}}')
  local k6_rps p50 p95 p99 fail dropped
  k6_rps=$(echo "$summary"  | jq -r '.metrics.http_reqs.values.rate // ""')
  p50=$(echo "$summary"     | jq -r '.metrics.http_req_duration.values.med // ""')
  p95=$(echo "$summary"     | jq -r '.metrics.http_req_duration.values["p(95)"] // ""')
  p99=$(echo "$summary"     | jq -r '.metrics.http_req_duration.values["p(99)"] // ""')
  fail=$(echo "$summary"    | jq -r '.metrics.http_req_failed.values.rate // 0')
  dropped=$(echo "$summary" | jq -r '.metrics.dropped_iterations.values.count // 0')

  echo "$MODE,$setup,$rate,$mrpc,0,$run,$W_RPS,$k6_rps,$p50,$p95,$p99,$fail,$dropped,$W_CLIENT_CPU,$W_SERVER_CPU,$W_HS,$W_HS_PER_S,$W_REUSED,$W_ERRORS,$W_CPU_PER_REQ_US,$W_CPU_PER_HS_US,0,0,$(cert_key),$(date -u +%FT%TZ),$SESSION" >> "$CSV"
  echo "    rps=$W_RPS p99=$p99 cpu/req=${W_CPU_PER_REQ_US}us hs/s=$W_HS_PER_S reused=$W_REUSED errors=$W_ERRORS"

  sleep "$COOLDOWN_S"
}

for RUN in $(seq 1 "$N_RUNS"); do
  # Randomize setup order in each run
  for SETUP in $(printf "%s\n" "${SETUPS[@]}" | shuf); do
    apply_setup "$SETUP"

    if [ "$MODE" = "handshake" ]; then
      apply_dr "$SETUP" 1
      warmup
      for RATE in $(printf "%s\n" $RATES | shuf); do
        one_point "$SETUP" "$RATE" 1 "$RUN"
      done

    else  # mrpc
      for M in $MRPCS; do
        apply_dr "$SETUP" "$M"
        warmup
        one_point "$SETUP" "$MRPC_RATE" "$M" "$RUN"
      done
    fi
  done
done

echo "Done. Results appended to $CSV"
