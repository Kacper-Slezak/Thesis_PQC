#!/bin/bash
# R2: did the client not offer a ticket, or did the server reject it?
# (vault: Inzynierka_Kampania_koncowa_plan.md, section 5)
# Captures inbound mTLS traffic in the server pod's network namespace (ephemeral debug
# container with tcpdump, image nicolaka/netshoot) while k6 runs, then counts ClientHello /
# ServerHello with the pre_shared_key extension (05_analytics/r2_psk_count.py) and compares
# with the Envoy counters of the same window. Diagnostic only, not a thesis result.
# Needs a running cluster (setup_cluster.sh). About 5 min per setting.
# Usage: ./run_r2_capture.sh 2>&1 | tee run_r2.log
set -eo pipefail
cd "$(dirname "$0")"
source ./01_scripts/lib_setups.sh

RATE="${RATE:-300}"
MRPC="${MRPC:-1}"
KEYS="${KEYS:-1 64}"            # max_session_keys settings (1 = Envoy default)
SETUP="${SETUP:-mtls1.3-postquantum}"
CAPTURE_S="${CAPTURE_S:-20}"
IMAGE="${IMAGE:-nicolaka/netshoot:v0.13}"
K6_SCRIPT=./03_test_scripts/main_k6_scenarios.js
OUT=./04_results/R2_capture_$(date +%Y%m%d_%H%M)
mkdir -p "$OUT"
trap cleanup_mesh_config EXIT

K6_POD=$(kubectl get pods -l app=k6 -o jsonpath='{.items[0].metadata.name}')
HTTPBIN_POD=$(kubectl get pods -l app=httpbin -o jsonpath='{.items[0].metadata.name}')
CAP=r2cap$(date +%H%M%S)        # ephemeral container names must be unique per pod

kubectl debug "$HTTPBIN_POD" -c "$CAP" --image="$IMAGE" --target=istio-proxy -- sleep 86400 >/dev/null
until [ -n "$(kubectl get pod "$HTTPBIN_POD" -o jsonpath="{.status.ephemeralContainerStatuses[?(@.name==\"$CAP\")].state.running}")" ]; do
  sleep 3
done

echo "setting,rate,mrpc,max_session_keys,envoy_server_handshakes,envoy_session_reused,client_hello,client_hello_psk,server_hello,server_hello_psk,incomplete" > "$OUT/r2.csv"
for K in $KEYS; do
  echo "=== R2 $SETUP rate=$RATE mrpc=$MRPC max_session_keys=$K"
  MAX_SESSION_KEYS=$K apply_setup "$SETUP"
  apply_dr "$SETUP" "$MRPC"
  kubectl exec -i "$K6_POD" -c k6 -- k6 run -e TEST_TYPE=handshake -e RATE="$RATE" \
    -e DURATION="$(( CAPTURE_S + 30 ))s" - < "$K6_SCRIPT" > /dev/null &
  K6_PID=$!
  sleep 15
  snapshot "$K6_POD" C0; snapshot "$HTTPBIN_POD" S0
  kubectl exec "$HTTPBIN_POD" -c "$CAP" -- timeout "$CAPTURE_S" \
    tcpdump -i eth0 -s 0 -w /tmp/r2.pcap 'tcp port 8080' 2>/dev/null || true
  snapshot "$K6_POD" C1; snapshot "$HTTPBIN_POD" S1
  wait "$K6_PID" || echo "Warning: k6 exited with an error"
  PCAP="$OUT/r2_msk$K.pcap"
  kubectl exec "$HTTPBIN_POD" -c "$CAP" -- cat /tmp/r2.pcap > "$PCAP"
  python3 -I ./05_analytics/r2_psk_count.py "$PCAP" | tee "$OUT/r2_msk$K.txt"
  HS=$(( S1_HS - S0_HS )); RU=$(( (C1_REUSED - C0_REUSED) + (S1_REUSED - S0_REUSED) ))
  echo "    envoy: handshakes=$HS session_reused(client+server)=$RU share=$(divide "$RU" "$(( 2 * HS ))" 3)"
  vals=$(awk '{print $2}' "$OUT/r2_msk$K.txt" | head -5 | paste -sd,)
  echo "$SETUP,$RATE,$MRPC,$K,$HS,$RU,$vals" >> "$OUT/r2.csv"
  sleep 10
done
echo "Done. Results in $OUT (the ephemeral container stays until the pod restarts)"
