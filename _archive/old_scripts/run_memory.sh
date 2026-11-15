#!/bin/bash
# Memory of the sidecars vs number of concurrent connections (keep-alive, no limit on mrpc).
#
# For every setup: restart both pods (clean memory), then hold LEVELS concurrent
# connections in increasing order and sample memory SAMPLES times at each level.
#
# Usage:
#   ./run_memory.sh [setups...]
# Example (about 1 h):
#   N_RUNS=2 LEVELS="0 50 100 200 300 400" ./run_memory.sh plaintext mtls1.3-x25519 mtls1.3-postquantum
set -eo pipefail
cd "$(dirname "$0")"
source ./01_scripts/lib_setups.sh

N_RUNS="${N_RUNS:-2}"                    # runs (setup order shuffled per run)
LEVELS="${LEVELS:-0 50 100 200 300 400}" # concurrent connections, always increasing
DELAY="${DELAY:-5}"                      # server delay [s] -> load = conns / DELAY req/s
RAMP_S="${RAMP_S:-20}"                   # ramp-up of connections [s]
SETTLE_S="${SETTLE_S:-20}"               # wait after the ramp before the first sample [s]
SAMPLES="${SAMPLES:-3}"                  # samples per level
EVERY_S="${EVERY_S:-15}"                 # time between samples [s]
SESSION="${SESSION:-1}"
K6_SCRIPT=./03_test_scripts/k6_connections.js
OUT=./04_results/Summary
CSV=$OUT/memory.csv
HOLD_S=$(( SETTLE_S + SAMPLES * EVERY_S + 5 ))

if [ "$#" -gt 0 ]; then SETUPS=("$@"); else SETUPS=(plaintext mtls1.3-x25519 mtls1.3-postquantum); fi
mkdir -p "$OUT"
./01_scripts/record_env.sh "$OUT/environment_memory_$(date +%Y%m%d_%H%M%S).txt" || true
trap cleanup_mesh_config EXIT

if [ ! -f "$CSV" ]; then
  echo "setup,run,conns_target,sample,client_conns,server_conns,client_envoy_alloc_b,client_envoy_heap_b,client_cg_current_b,client_cg_anon_b,client_cg_sock_b,server_envoy_alloc_b,server_envoy_heap_b,server_cg_current_b,server_cg_anon_b,server_cg_sock_b,k6_fail_rate,timestamp,session" > "$CSV"
fi

# Name of the running pod with a given label (skips pods that are terminating)
pod_of() {
  kubectl get pods -l "app=$1" -o go-template='{{range .items}}{{if not .metadata.deletionTimestamp}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | head -1
}

# Restart both pods so every setup starts from the same, clean memory state
restart_pods() {
  kubectl rollout restart deployment/k6-deploy deployment/httpbin >/dev/null
  kubectl rollout status deployment/k6-deploy --timeout=180s >/dev/null
  kubectl rollout status deployment/httpbin --timeout=180s >/dev/null
  until [ "$(kubectl get pods -l 'app in (k6,httpbin)' --no-headers 2>/dev/null | wc -l)" -eq 2 ]; do sleep 3; done
  K6_POD=$(pod_of k6)
  HTTPBIN_POD=$(pod_of httpbin)
  sleep 30
}

# Established TCP connections in the pod: remote port 8080 (client side, mTLS to server)
# or local port 15006 (server side, inbound mTLS); /proc/net/tcp keeps ports in hex
conns() {
  local pod=$1 which=$2
  kubectl exec "$pod" -c istio-proxy -- cat /proc/net/tcp /proc/net/tcp6 2>/dev/null | awk -v w="$which" '
    $4 == "01" {
      split($2, l, ":"); split($3, r, ":")
      if (w == "client" && r[2] == "1F90") n++
      if (w == "server" && l[2] == "3A9E") n++
    } END { print n + 0 }'
}

# Memory of the istio-proxy container: Envoy allocator and cgroup (bytes)
mem() {
  local pod=$1 m s
  m=$(kubectl exec "$pod" -c istio-proxy -- curl -s localhost:15000/memory)
  s=$(kubectl exec "$pod" -c istio-proxy -- cat /sys/fs/cgroup/memory.stat)
  printf '%s,%s,%s,%s,%s' \
    "$(echo "$m" | grep -o '"allocated": *"[0-9]*"' | grep -o '[0-9]*')" \
    "$(echo "$m" | grep -o '"heap_size": *"[0-9]*"' | grep -o '[0-9]*')" \
    "$(kubectl exec "$pod" -c istio-proxy -- cat /sys/fs/cgroup/memory.current)" \
    "$(echo "$s" | awk '$1 == "anon" {print $2}')" \
    "$(echo "$s" | awk '$1 == "sock" {print $2}')"
}

sample_row() {
  local setup=$1 run=$2 level=$3 i=$4 fail=$5
  echo "$setup,$run,$level,$i,$(conns "$K6_POD" client),$(conns "$HTTPBIN_POD" server),$(mem "$K6_POD"),$(mem "$HTTPBIN_POD"),$fail,$(date -u +%Y-%m-%dT%H:%M:%SZ),$SESSION" >> "$CSV"
}

for RUN in $(seq 1 "$N_RUNS"); do
  for SETUP in $(printf "%s\n" "${SETUPS[@]}" | shuf); do
    echo "=== run $RUN: $SETUP ==="
    apply_setup "$SETUP"
    apply_dr "$SETUP" 0
    restart_pods
    for LEVEL in $LEVELS; do
      echo "--- $SETUP conns=$LEVEL ---"
      if [ "$LEVEL" = "0" ]; then
        for i in $(seq 1 "$SAMPLES"); do sample_row "$SETUP" "$RUN" 0 "$i" ""; sleep "$EVERY_S"; done
        continue
      fi
      kubectl exec "$K6_POD" -c k6 -- rm -f /tmp/summary_mem.json >/dev/null 2>&1 || true
      kubectl exec -i "$K6_POD" -c k6 -- k6 run -e CONNS="$LEVEL" -e DELAY="$DELAY" \
        -e RAMP="${RAMP_S}s" -e HOLD="${HOLD_S}s" - < "$K6_SCRIPT" > /dev/null &
      K6_PID=$!
      sleep $(( RAMP_S + SETTLE_S ))
      for i in $(seq 1 "$SAMPLES"); do sample_row "$SETUP" "$RUN" "$LEVEL" "$i" "pending"; sleep "$EVERY_S"; done
      wait "$K6_PID" || echo "Warning: k6 exited with an error (out of memory? lower LEVELS)"
      FAIL=$(kubectl exec "$K6_POD" -c k6 -- cat /tmp/summary_mem.json 2>/dev/null \
        | python3 -c 'import json,sys; print(json.load(sys.stdin)["metrics"]["http_req_failed"]["values"]["rate"])' 2>/dev/null || echo "nan")
      sed -i "s/,pending,\(.*\)$/,$FAIL,\1/" "$CSV"
      sleep 10
    done
  done
done
echo "Done. Results appended to $CSV"
