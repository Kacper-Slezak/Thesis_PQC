#!/bin/bash
# Live demo with monitoring ON (not a measurement for the result tables): one continuous k6 load,
# the mesh configuration is switched every PHASE_S seconds, Prometheus/Grafana record everything.
# Gives time series for the "test environment and validation" chapter: sidecar CPU and memory
# (cAdvisor), request rate and latency (Istio telemetry), TLS handshakes and key-exchange groups
# (Envoy ssl.* stats, exported via proxyStatsMatcher), with the phase boundaries.
#
# Phases (default): plaintext -> X25519 full -> X25519MLKEM768 full -> X25519 resumed
#                   -> X25519MLKEM768 resumed -> plaintext
# Needs a running cluster (setup_cluster.sh). About PHASES x PHASE_S + 5 min (default ~35 min).
#
# Usage:
#   ./run_live.sh 2>&1 | tee run_live.log
#   PHASE_S=180 RATE=200 MRPC=1 ./run_live.sh
# Output: 04_results/Live_<stamp>/ phases.csv, prom_*.json, k6 summary; then
#   .venv/bin/python -I 05_analytics/plot_live.py 04_results/Live_<stamp>
# Grafana: kubectl port-forward -n istio-system svc/grafana 3000:3000, open http://localhost:3000,
#   dashboards "Istio Performance Dashboard" / "Istio Workload Dashboard", time range = phases.csv.
set -eo pipefail
cd "$(dirname "$0")"
source ./01_scripts/lib_setups.sh

PHASE_S="${PHASE_S:-300}"
RATE="${RATE:-200}"
MRPC="${MRPC:-1}"
PHASES="${PHASES:-plaintext mtls1.3-x25519-full mtls1.3-postquantum-full mtls1.3-x25519 mtls1.3-postquantum plaintext}"
export MAX_SESSION_KEYS="${MAX_SESSION_KEYS:-16}"     # same resumed arms as in the final campaign
K6_SCRIPT=./03_test_scripts/main_k6_scenarios.js
OUT=04_results/Live_$(date +%Y%m%d_%H%M)
mkdir -p "$OUT"
PF_PID=""
cleanup() { [ -n "$PF_PID" ] && kill "$PF_PID" 2>/dev/null; cleanup_mesh_config; }
trap cleanup EXIT

echo "=== monitoring on"
./01_scripts/quiet_mode.sh off
kubectl rollout status deploy/prometheus -n istio-system --timeout=180s
kubectl rollout status deploy/grafana -n istio-system --timeout=180s

# Envoy TLS counters (ssl.*) are already exported to Prometheus: k6.yaml and backend.yaml set
# proxyStatsMatcher (.*ssl.*, .*tls.*, cluster.inbound.*upstream_rq_total). Do not override it:
# the matcher decides which stats Envoy creates at all, and run_sweeps.sh needs upstream_rq_total.
K6_POD=$(kubectl get pods -l app=k6 -o go-template='{{range .items}}{{if not .metadata.deletionTimestamp}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | head -1)
[ -n "$K6_POD" ] || { echo "no running k6 pod"; exit 1; }
./01_scripts/record_env.sh "$OUT/environment.txt" || true

N=$(echo $PHASES | wc -w)
TOTAL=$(( N * PHASE_S + 60 ))
echo "=== k6: $RATE req/s for ${TOTAL}s (mrpc=$MRPC per phase), $N phases x ${PHASE_S}s"
echo "phase,setup,start_utc,end_utc,start_unix,end_unix" > "$OUT/phases.csv"
apply_setup "$(echo $PHASES | awk '{print $1}')"
apply_dr "$(echo $PHASES | awk '{print $1}')" "$MRPC"
kubectl exec "$K6_POD" -c k6 -- rm -f /tmp/summary.json >/dev/null 2>&1 || true
kubectl exec -i "$K6_POD" -c k6 -- k6 run -e TEST_TYPE=handshake -e RATE="$RATE" -e DURATION="${TOTAL}s" - \
  < "$K6_SCRIPT" > "$OUT/k6.log" 2>&1 &
K6_PID=$!
sleep 30                                                    # k6 warm-up before the first phase

i=0
for S in $PHASES; do
  i=$(( i + 1 ))
  if [ "$i" -gt 1 ]; then apply_setup "$S"; apply_dr "$S" "$MRPC"; fi   # ~25 s of switching inside the phase
  T0=$(date -u +%s); echo "--- $(date '+%T') phase $i: $S"
  sleep $(( PHASE_S - ( $(date -u +%s) - T0 ) > 0 ? PHASE_S - ( $(date -u +%s) - T0 ) : 0 ))
  T1=$(date -u +%s)
  echo "$i,$S,$(date -u -d @"$T0" +%FT%TZ),$(date -u -d @"$T1" +%FT%TZ),$T0,$T1" >> "$OUT/phases.csv"
done
wait "$K6_PID" || echo "Warning: k6 exited with an error (connections are reset at every switch)"
kubectl exec "$K6_POD" -c k6 -- cat /tmp/summary.json > "$OUT/k6_summary.json" 2>/dev/null || true
sleep 20                                                    # last scrape

echo "=== export from Prometheus"
kubectl port-forward -n istio-system svc/prometheus 19090:9090 >/dev/null 2>&1 &
PF_PID=$!
sleep 5
START=$(awk -F, 'NR==2{print $5 - 60}' "$OUT/phases.csv")
END=$(awk -F, 'END{print $6 + 30}' "$OUT/phases.csv")
prom() {   # name query
  curl -s -G localhost:19090/api/v1/query_range --data-urlencode "query=$2" \
    --data-urlencode "start=$START" --data-urlencode "end=$END" --data-urlencode "step=5" > "$OUT/prom_$1.json"
  echo "  $1: $(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d["status"], len(d["data"]["result"]), "series")' "$OUT/prom_$1.json")"
}
W='namespace="default",container="istio-proxy"'
prom cpu        "sum by (pod) (rate(container_cpu_usage_seconds_total{$W}[30s]))"
prom memory     "sum by (pod) (container_memory_working_set_bytes{$W})"
prom envoy_alloc "sum by (pod) (envoy_server_memory_allocated{namespace=\"default\"})"
prom rps        "sum(rate(istio_requests_total{reporter=\"destination\",destination_workload=\"httpbin\"}[30s]))"
prom p50        "histogram_quantile(0.5, sum by (le) (rate(istio_request_duration_milliseconds_bucket{reporter=\"destination\",destination_workload=\"httpbin\"}[30s])))"
prom p99        "histogram_quantile(0.99, sum by (le) (rate(istio_request_duration_milliseconds_bucket{reporter=\"destination\",destination_workload=\"httpbin\"}[30s])))"
prom handshakes "sum(rate({__name__=~\"envoy_listener_ssl_handshake\",namespace=\"default\",pod=~\"httpbin.*\"}[30s]))"
prom reused     "sum(rate({__name__=~\"envoy_listener_ssl_session_reused\",namespace=\"default\",pod=~\"httpbin.*\"}[30s]))"
# one query per key-exchange group: rate() drops the metric name, so "sum by (__name__)" cannot be used
prom curve_X25519         "sum(rate(envoy_listener_ssl_curves_X25519{namespace=\"default\",pod=~\"httpbin.*\"}[30s]))"
prom curve_X25519MLKEM768 "sum(rate(envoy_listener_ssl_curves_X25519MLKEM768{namespace=\"default\",pod=~\"httpbin.*\"}[30s]))"
prom mtls       "sum by (connection_security_policy) (rate(istio_requests_total{reporter=\"destination\",destination_workload=\"httpbin\"}[30s]))"
echo "Done: $OUT  (plots: .venv/bin/python -I 05_analytics/plot_live.py $OUT)"
echo "Grafana is still running for screenshots; afterwards: ./01_scripts/quiet_mode.sh on"
trap - EXIT; kill "$PF_PID" 2>/dev/null; cleanup_mesh_config
