#!/bin/bash
# Shared helper functions for benchmark setups and metric collection

ALL_SETUPS=(
    "plaintext"
    "mtls1.3-default"
    "mtls1.2-gcm"
    "mtls1.2-gcm256"
    "mtls1.2-chacha"
    "mtls1.2-cbc"
    "mtls1.3-postquantum"
    "mtls1.3-x25519"
    "mtls1.3-x25519-full"
    "mtls1.3-postquantum-full"
)

COOLDOWN_S="${COOLDOWN_S:-45}"

# Apply EnvoyFilter or PeerAuthentication for given setup
apply_setup() {
    local setup_name=$1 ef=""
    kubectl delete envoyfilter --all -n default >/dev/null 2>&1 || true
    kubectl delete peerauthentication disable-mtls -n default >/dev/null 2>&1 || true

    case $setup_name in
    plaintext) ef=peerauthentication_plaintext.yaml ;;
    mtls1.3-default)     ;;
    mtls1.2-gcm)         ef=envoyfilter_gcm.yaml ;;
    mtls1.2-gcm256)      ef=envoyfilter_gcm256.yaml ;;
    mtls1.2-chacha)      ef=envoyfilter_chacha.yaml ;;
    mtls1.2-cbc)         ef=envoyfilter_cbc.yaml ;;
    mtls1.3-postquantum) ef=envoyfilter_pqc.yaml ;;
    mtls1.3-x25519)      ef=envoyfilter_x25519.yaml ;;
    mtls1.3-x25519-full)ef=envoyfilter_x25519_full.yaml ;;
    mtls1.3-postquantum-full) ef=envoyfilter_pqc_full.yaml ;;
    *) echo "Unknown setup '$name'" >&2; return 1 ;;
  esac
  [ -n "$ef" ] && kubectl apply -f "./02_manifests/$ef" >/dev/null
  sleep 15
}

# Apply DestinationRule (traffic policy and requests per connection)
apply_dr() {
    local dr_name=$1 mrpc=${2:-0} tls="" mr=""
    [ "dr" = "$dr_name" ] && tls=$'  tls:\n    mode: DISABLE'
    [ "$mrpc" != "0" ] && mr="        maxRequestsPerConnection: $mrpc"
    kubectl delete destinationrule disable-mtls-client force-nokeepalive -n default >/dev/null 2>&1 || true
    kubectl apply -f - >/dev/null <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: dr
  namespace: default
spec:
  host: httpbin.default.svc.cluster.local
  trafficPolicy:
${tls}
    connectionPool:
      http:
${mr}
        h2UpgradePolicy: DO_NOT_UPGRADE
EOF
  sleep 10
}

# Reset mesh configuration to default state
cleanup_mesh_config() {
  kubectl delete destinationrule dr -n default >/dev/null 2>&1 || true
  kubectl delete peerauthentication disable-mtls -n default >/dev/null 2>&1 || true
  kubectl delete envoyfilter --all -n default >/dev/null 2>&1 || true
}

# Expected key exchange curve for verification
expected_curve() {
  case $1 in
    mtls1.3-postquantum|mtls1.3-postquantum-full) echo "X25519MLKEM768" ;;
    mtls1.3-x25519|mtls1.3-x25519-full)           echo "X25519" ;;
    *)                                            echo "" ;;
  esac
}

# Dump Envoy stats from localhost:15000
stats_dump() {
  kubectl exec "$1" -c istio-proxy -- \
    curl -s -G localhost:15000/stats --data-urlencode 'filter=ssl\.|upstream_rq_total'
}

# Extract counter value from stats dump
counter() {
  echo "$1" | grep -E "$2" | awk -F': ' '{ suma += $2 } END { print suma + 0 }'
}

# Read cgroup CPU usage in microseconds
cpu_usec() {
  kubectl exec "$1" -c istio-proxy -- grep usage_usec /sys/fs/cgroup/cpu.stat | cut -d' ' -f2
}

# Regex filters for Envoy stats
RE_REQUESTS='^cluster\.inbound\|[0-9]+\|\|;?\.upstream_rq_total:'
RE_HANDSHAKE='\.ssl\.handshake:'
RE_REUSED='\.ssl\.session_reused:'
RE_ERRORS='\.ssl\.connection_error:'
RE_CURVES='\.ssl\.curves\.'

# Snapshot CPU and stats counters for a pod
snapshot() {
  local pod=$1 p=$2
  local dump
  dump=$(stats_dump "$pod")
  printf -v "${p}_CPU"    '%s' "$(cpu_usec "$pod")"
  printf -v "${p}_REQ"    '%s' "$(counter "$dump" "$RE_REQUESTS")"
  printf -v "${p}_HS"     '%s' "$(counter "$dump" "$RE_HANDSHAKE")"
  printf -v "${p}_REUSED" '%s' "$(counter "$dump" "$RE_REUSED")"
  printf -v "${p}_ERR"    '%s' "$(counter "$dump" "$RE_ERRORS")"
  printf -v "${p}_CURVES" '%s' "$(counter "$dump" "$RE_CURVES")"
  printf -v "${p}_X25519" '%s' "$(counter "$dump" '\.ssl\.curves\.X25519:')"
  printf -v "${p}_MLKEM"  '%s' "$(counter "$dump" '\.ssl\.curves\.X25519MLKEM768:')"
}

# Safe division helper with scale
divide() {
  if [ "$2" = "0" ]; then echo "n/a"; else echo "scale=${3:-1}; $1 / $2" | bc; fi
}

# Run k6 and measure stats during steady window
measure_window() {
  local k6pod=$1 srv=$2 warm=$3 steady=$4 script=$5
  shift 5

  kubectl exec "$k6pod" -c k6 -- rm -f /tmp/summary.json >/dev/null 2>&1 || true
  kubectl exec -i "$k6pod" -c k6 -- k6 run "$@" - < "$script" > /dev/null &
  local k6_pid=$!

  sleep "$warm"

  local t0 t1
  t0=$(date +%s.%N)
  W_START=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  snapshot "$k6pod" C0
  snapshot "$srv"   S0

  sleep "$steady"

  t1=$(date +%s.%N)
  W_END=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  snapshot "$k6pod" C1
  snapshot "$srv"   S1

  wait "$k6_pid" || echo "Warning: k6 exited with an error"

  W_DUR=$(echo "$t1 - $t0" | bc)

  local requests=$(( S1_REQ - S0_REQ ))
  local cpu_client=$(( C1_CPU - C0_CPU ))
  local cpu_server=$(( S1_CPU - S0_CPU ))
  local cpu_total=$(( cpu_client + cpu_server ))

  W_HS=$(( S1_HS - S0_HS ))
  W_REUSED=$(( (C1_REUSED - C0_REUSED) + (S1_REUSED - S0_REUSED) ))
  W_ERRORS=$(( (C1_ERR - C0_ERR) + (S1_ERR - S0_ERR) ))
  W_CURVE_ALL=$(( S1_CURVES - S0_CURVES ))
  W_CURVE_X25519=$(( S1_X25519 - S0_X25519 ))
  W_CURVE_MLKEM=$(( S1_MLKEM - S0_MLKEM ))

  W_RPS=$(divide "$requests" "$W_DUR")
  W_HS_PER_S=$(divide "$W_HS" "$W_DUR")
  W_CLIENT_CPU=$(divide "$cpu_client" "$(echo "$W_DUR * 1000000" | bc)" 3)
  W_SERVER_CPU=$(divide "$cpu_server" "$(echo "$W_DUR * 1000000" | bc)" 3)
  W_CPU_PER_REQ_US=$(divide "$cpu_total" "$requests")
  W_CPU_PER_HS_US=$(divide "$cpu_total" "$W_HS")
  W_CURVES="X25519=${W_CURVE_X25519};X25519MLKEM768=${W_CURVE_MLKEM};all=${W_CURVE_ALL}"
}

# Verify curve and save evidence to CSV
record_evidence() {
  local setup=$1 label=$2
  local file=./04_results/Summary/curve_evidence.csv
  local exp verdict="n/a"

  [ "$setup" = "plaintext" ] && return 0
  exp=$(expected_curve "$setup")

  if [ ! -f "$file" ]; then
    echo "setup,label,window_start,window_end,curve_deltas,expected_curve,handshakes,conn_errors,verdict" > "$file"
  fi

  if [ -n "$exp" ] && [ "$W_HS" -gt 0 ]; then
    local got=$W_CURVE_X25519
    [ "$exp" = "X25519MLKEM768" ] && got=$W_CURVE_MLKEM
    if [ "$got" -gt 0 ] && [ "$got" -eq "$W_CURVE_ALL" ] && [ "$W_ERRORS" -eq 0 ]; then
      verdict=PASS
    else
      verdict=FAIL
      echo "WARNING: curve evidence FAILED for $setup: $W_CURVES errors=$W_ERRORS (expected only $exp)"
    fi
  fi

  echo "$setup,$label,$W_START,$W_END,\"$W_CURVES\",$exp,$W_HS,$W_ERRORS,$verdict" >> "$file"
}

# Certificate key type (RSA or PQC)
cert_key() {
  echo "${CERT_KEY:-RSA}"
}
