#! /bin/bash

set -eo pipefail

NAMESPACE="default"
MANIFEST_DIR="02_manifests"
RESULTS_DIR="04_results/Summary"

mkdir -p "$RESULTS_DIR"

K6_POD=$(kubectl get pods -n "$NAMESPACE" -l app=k6 -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$K6_POD" ]; then
    echo "K6 pod not found in namespace '$NAMESPACE'. Please ensure the k6
    load generator is deployed and running."
    exit 1
fi
echo "K6 pod found: $K6_POD"

# Statystyki SSL czytamy z serwera (httpbin), bo tam kończy się handshake
HTTPBIN_POD=$(kubectl get pods -n "$NAMESPACE" -l app=httpbin -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$HTTPBIN_POD" ]; then
    echo "httpbin pod not found in namespace '$NAMESPACE'."
    exit 1
fi
echo "httpbin pod found: $HTTPBIN_POD"

CONFIGURATIONS_NAMES=(
    "mtls1.3-default"
    "mtls1.2-gcm"
    "mtls1.2-chacha20"
    "mtls1.2-gcm256"
    "mtls1.2-cbc"
    "mtls1.3-postquantum"
    "mtls1.3-x25519"
)

MANIFESTS=(
    ""  # mtls1.3-default: bez EnvoyFilter
    "${MANIFEST_DIR}/envoyfilter_gcm.yaml"
    "${MANIFEST_DIR}/envoyfilter_gcm256.yaml"
    "${MANIFEST_DIR}/envoyfilter_chacha.yaml"
    "${MANIFEST_DIR}/envoyfilter_cbc.yaml"
    "${MANIFEST_DIR}/envoyfilter_pqc.yaml"
    "${MANIFEST_DIR}/envoyfilter_x25519.yaml"
)

EXPECTED_CIPHERS=(
  "TLS_AES_(128|256)_GCM_SHA(256|384)"
  "ECDHE-RSA-AES128-GCM-SHA256"
  "ECDHE-RSA-AES256-GCM-SHA384"
  "ECDHE-RSA-CHACHA20-POLY1305"
  "ECDHE-RSA-AES128-SHA256"
  "TLS_AES_(128|256)_GCM_SHA(256|384)"
  "TLS_AES_(128|256)_GCM_SHA(256|384)"
)

EXPECTED_CURVES=(
  "X25519"
  "X25519"
  "X25519"
  "X25519"
  "X25519"
  "X25519MLKEM768"
  "X25519"
)

check_delta() {
  local before="$1" after="$2" name_regex="$3" stat_type="$4"
  PATTERN="ssl\.${stat_type}\.(${name_regex}):" awk -F': ' '
    NR == FNR { before[$1] = $2; next }                  
    $0 ~ ENVIRON["PATTERN"] && $2 + 0 > before[$1] + 0 { found = 1 }
    END { exit !found }
  ' "$before" "$after"
}


fetch_ssl_stats() {
  local full
  full=$(mktemp)
  kubectl exec "$1" -c istio-proxy -- curl -s localhost:15000/stats > "$full" 2>/dev/null || true
  grep -i -E "ssl\.(ciphers|curves)" "$full" > "$2" || true
  wc -l < "$full"
  rm -f "$full"
}

declare -A FAILS=()

for i in "${!CONFIGURATIONS_NAMES[@]}"; do
    CONFIG_NAME="${CONFIGURATIONS_NAMES[$i]}"
    MANIFEST="${MANIFESTS[$i]}"
    EXPECTED_CIPHER="${EXPECTED_CIPHERS[$i]}"
    EXPECTED_CURVE="${EXPECTED_CURVES[$i]}"

    echo "Processing configuration: $CONFIG_NAME"
    kubectl delete envoyfilter --all -n "$NAMESPACE" >/dev/null 2>&1 || true

    if [ -n "$MANIFEST" ]; then
        echo "Applying configuration: $CONFIG_NAME"
        kubectl apply -f "$MANIFEST"
    fi

    echo "Waiting for configuration to take effect..."
    sleep 10

    BEFORE_STATS=$(mktemp)
    AFTER_STATS=$(mktemp)
    K6_LOG=$(mktemp)

    FULL_BEFORE=$(fetch_ssl_stats "$HTTPBIN_POD" "$BEFORE_STATS")

    echo "Generating traffic (k6 -> httpbin)..."
    K6_EXIT=0
    echo "import http from 'k6/http'; export default function () { http.get('http://httpbin.default.svc.cluster.local:8000/get'); }" \
        | kubectl exec -i "$K6_POD" -c k6 -- k6 run --vus 5 --duration 8s - > "$K6_LOG" 2>&1 \
        || K6_EXIT=$?
    K6_LINE=$(grep -E "http_reqs|http_req_failed" "$K6_LOG" | tr -s ' ' | tr '\n' ';')
    rm -f "$K6_LOG"

    FULL_AFTER=$(fetch_ssl_stats "$HTTPBIN_POD" "$AFTER_STATS")

    DIAG="ok"
    if [ "${FULL_AFTER:-0}" -eq 0 ]; then
        DIAG="ADMIN_STATS_UNREACHABLE: curl localhost:15000/stats in istio-proxy returned nothing"
    elif [ ! -s "$AFTER_STATS" ]; then
        DIAG="NO_SSL_COUNTERS: no ssl.ciphers/curves lines (no TLS handshake yet, or proxyStatsMatcher excludes ssl)"
    fi

    OUT_FILE="${RESULTS_DIR}/verify_${CONFIG_NAME}.txt"
    {
        echo "setup:        $CONFIG_NAME"
        echo "date:         $(date -u +%FT%TZ)"
        echo "k6_exit:      $K6_EXIT"
        echo "k6:           ${K6_LINE:-none}"
        echo "stats_lines:  before=${FULL_BEFORE:-0} after=${FULL_AFTER:-0}"
        echo "diagnosis:    $DIAG"
        echo "--- delta (after - before, non-zero only) ---"
        awk -F': ' 'FILENAME==ARGV[1]{b[$1]=$2; next} {d=$2-b[$1]; if (d!=0) print $1 ": " d}' "$BEFORE_STATS" "$AFTER_STATS"
        echo "--- cumulative after ---"
        cat "$AFTER_STATS"
    } | tee "$OUT_FILE"

    CIPHER_OK=FAIL
    CURVE_OK=FAIL
    if check_delta "$BEFORE_STATS" "$AFTER_STATS" "$EXPECTED_CIPHER" "ciphers"; then CIPHER_OK=PASS; fi
    if check_delta "$BEFORE_STATS" "$AFTER_STATS" "$EXPECTED_CURVE" "curves"; then CURVE_OK=PASS; fi
    rm -f "$BEFORE_STATS" "$AFTER_STATS"

    echo ">>> Expected cipher counter incremented: $CIPHER_OK"
    echo ">>> Expected curve counter incremented:  $CURVE_OK"

    if [ "$CIPHER_OK" != "PASS" ] || [ "$CURVE_OK" != "PASS" ]; then
        FAILS["$CONFIG_NAME"]="cipher_ok=$CIPHER_OK curve_ok=$CURVE_OK ($DIAG)"
    fi
done

if [ "${#FAILS[@]}" -gt 0 ]; then
    echo ""
    echo "Failed configurations:"
    for name in "${!FAILS[@]}"; do
        echo "  $name: ${FAILS[$name]}"
    done
    exit 1
fi
if [ ${#FAILS[@]} -eq 0 ]; then
  echo "All setups negotiated the expected cryptographic algorithms. Ready for benchmark execution!"
else
  echo "WARNING: The following setups did not match expectations (inspect logs for details):"
  for k in "${!FAILS[@]}"; do
    echo "  - $k: ${FAILS[$k]}"
  done
fi

kubectl delete envoyfilter --all -n "$NAMESPACE" >/dev/null 2>&1 || true