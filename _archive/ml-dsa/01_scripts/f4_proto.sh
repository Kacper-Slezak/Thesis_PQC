#!/usr/bin/env bash
# f4_proto.sh – prototyp F4: mTLS w siatce Istio 1.31.x z certyfikatami RSA-2048 / ECDSA P-256 / ML-DSA-65
#
# POMYSŁ (dlaczego tak): pilot-agent w sidecarze Istio waliduje pliki certyfikatów funkcją Go
# tls.LoadX509KeyPair (kod 1.31.4), a według go.mod Istio 1.31 buduje się na Go 1.26, które nie zna
# ML-DSA (dochodzi w Go 1.27); "versions" pokaże wersję Go w pilot-agencie, "sdscheck" sprawdzi to w praktyce. Dlatego
# NIE używamy DestinationRule MUTUAL ani Sidecar.ingress.tls (obie ścieżki idą przez pilot-agenta).
# Zamiast tego: Istio zostaje w trybie plain (PeerAuthentication DISABLE + DestinationRule tls DISABLE,
# jak w setupie "plaintext" z F3), a TLS z certyfikatami z plików dokładamy EnvoyFilterem
# (tls_certificates/filename). Pliki czyta sam Envoy (BoringSSL), który ML-DSA obsługuje.
# Wszystkie trzy algorytmy idą tym samym mechanizmem, więc różnica = tylko algorytm podpisu.
# Dodatkowy punkt odniesienia "native" = zwykły mTLS z certyfikatami istiod (jak F3, ale na 1.31.x).
#
# KOLEJNOŚĆ (z katalogu głównego repo):
#   0) istioctl 1.31.4 w PATH:
#        curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.31.4 TARGET_ARCH=x86_64 sh -
#        export PATH=$PWD/istio-1.31.4/bin:$PATH
#   1) ./01_scripts/f4_proto.sh cluster      # NOWY klaster na Istio 1.31.4 (kasuje thesis-cluster!)
#   2) ./01_scripts/f4_proto.sh versions     # wersje Envoya / pilot-agenta w sidecarze
#   3) ./01_scripts/f4_proto.sh pki          # certyfikaty (docker + OpenSSL 3.5) -> ./f4_pki
#   4) ./01_scripts/f4_proto.sh deploy       # Secrety + montowanie do sidecarów (restart podów)
#   5) ./01_scripts/f4_proto.sh smoke all    # test dymny: kilka połączeń mTLS na każdy algorytm + dowody
#   6) ./01_scripts/f4_proto.sh sdscheck     # (opcjonalnie) dowód, że ścieżka pilot-agenta odrzuca ML-DSA
#   7) ./01_scripts/f4_proto.sh bench        # wstępne F4: mini-siatka (domyślnie ok. 1-1,5 h)
# Wyniki: 04_results/F4_proto/ (smoke_*.txt, sdscheck.txt, versions.txt, sweeps.csv).
#
# Zmienne bench: ARMS, RATES (domyślnie "100"), MRPCS (domyślnie "1 0"), N_RUNS (2), DURATION (60),
#                WARM_S, COOL_S, SETTLE_S, COOLDOWN_S, SESSION, QUIET=0 (nie wyłączaj Prometheusa).
set -o pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 1
# shellcheck source=/dev/null
source ./01_scripts/lib_setups.sh

NS=default
OUT=${OUT:-04_results/F4_proto}
PKI=${PKI:-$ROOT/f4_pki}
ISTIO_TARGET=${ISTIO_TARGET:-1.31.4}
ALGS=(rsa ecdsa mldsa)
mkdir -p "$OUT"

die()     { echo "BLAD: $*" >&2; exit 1; }
confirm() { [ "${YES:-0}" = 1 ] && return 0; local a; read -r -p "$1 [t/N] " a; [[ "$a" =~ ^[tTyY] ]]; }

pod_of() { kubectl get pods -n "$NS" -l "app=$1" -o json | jq -r '.items[] | select(.metadata.deletionTimestamp==null) | .metadata.name' | head -1; }
k6_pod()  { pod_of k6; }
srv_pod() { pod_of httpbin; }

alg_label() { case $1 in rsa) echo RSA ;; ecdsa) echo ECDSA ;; mldsa) echo MLDSA65 ;; *) echo RSA ;; esac; }

# ------------------------------------------------------------------ EnvoyFilter z TLS z plików
# $1 = rsa|ecdsa|mldsa   $2 = resumed|full
render_ef() {
  local alg=$1 mode=$2 sig="" cmk="" srv_resume=""
  if [ "$alg" = mldsa ]; then
    sig='                signature_algorithms: ["mldsa65"]'
  fi
  if [ "$mode" = full ]; then
    cmk='            max_session_keys: 0'
    srv_resume='            disable_stateless_session_resumption: true
            disable_stateful_session_resumption: true'
  fi
  cat <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: f4-${alg}-${mode}-client
  namespace: ${NS}
spec:
  workloadSelector:
    labels:
      app: k6
  configPatches:
  - applyTo: CLUSTER
    match:
      context: SIDECAR_OUTBOUND
      cluster:
        name: "outbound|8000||httpbin.default.svc.cluster.local"
    patch:
      operation: MERGE
      value:
        transport_socket:
          name: envoy.transport_sockets.tls
          typed_config:
            "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
${cmk}
            common_tls_context:
              tls_params:
                tls_minimum_protocol_version: TLSv1_3
                tls_maximum_protocol_version: TLSv1_3
                ecdh_curves: ["X25519MLKEM768"]
${sig}
              tls_certificates:
              - certificate_chain: {filename: /etc/f4/${alg}/tls.crt}
                private_key: {filename: /etc/f4/${alg}/tls.key}
              validation_context:
                trusted_ca: {filename: /etc/f4/${alg}/ca.crt}
---
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: f4-${alg}-${mode}-server
  namespace: ${NS}
spec:
  workloadSelector:
    labels:
      app: httpbin
  configPatches:
  - applyTo: FILTER_CHAIN
    match:
      context: SIDECAR_INBOUND
      listener:
        filterChain:
          destinationPort: 8080
    patch:
      operation: MERGE
      value:
        transport_socket:
          name: envoy.transport_sockets.tls
          typed_config:
            "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
            require_client_certificate: true
${srv_resume}
            common_tls_context:
              tls_params:
                tls_minimum_protocol_version: TLSv1_3
                tls_maximum_protocol_version: TLSv1_3
                ecdh_curves: ["X25519MLKEM768"]
${sig}
              tls_certificates:
              - certificate_chain: {filename: /etc/f4/${alg}/tls.crt}
                private_key: {filename: /etc/f4/${alg}/tls.key}
              validation_context:
                trusted_ca: {filename: /etc/f4/${alg}/ca.crt}
EOF
}

# Włącza jeden "ramię": Istio plain + EnvoyFilter z TLS z plików. $3 = maxRequestsPerConnection (0 = bez limitu)
apply_arm_f4() {
  local alg=$1 mode=$2 mrpc=${3:-1}
  kubectl delete envoyfilter --all -n "$NS" >/dev/null 2>&1 || true
  kubectl delete destinationrule f4-sdscheck -n "$NS" >/dev/null 2>&1 || true
  kubectl apply -f ./02_manifests/peerauthentication_plaintext.yaml >/dev/null || return 1
  render_ef "$alg" "$mode" | kubectl apply -f - >/dev/null || { echo "EnvoyFilter nie zostal przyjety" >&2; return 1; }
  apply_dr plaintext "$mrpc"          # DestinationRule: tls DISABLE + connectionPool (czeka 10 s)
  sleep "${F4_SETTLE:-15}"
}

# Dowolne ramię po nazwie: native-resumed|native-full|f4-<alg>-<resumed|full>
apply_arm_any() {
  local arm=$1 mrpc=${2:-1} alg mode
  case $arm in
    native-resumed) apply_setup mtls1.3-postquantum;      apply_dr mtls1.3-postquantum "$mrpc" ;;
    native-full)    apply_setup mtls1.3-postquantum-full; apply_dr mtls1.3-postquantum-full "$mrpc" ;;
    f4-*) alg=${arm#f4-}; alg=${alg%-*}; mode=${arm##*-}; apply_arm_f4 "$alg" "$mode" "$mrpc" ;;
    *) die "nieznane ramie '$arm'" ;;
  esac
}

arm_alg() {   # nazwa ramienia -> etykieta cert_key
  case $1 in native-*) echo RSA ;; f4-rsa-*) echo RSA ;; f4-ecdsa-*) echo ECDSA ;; f4-mldsa-*) echo MLDSA65 ;; *) echo RSA ;; esac
}

# ------------------------------------------------------------------ statystyki
stats_to() {   # pod plik -> znormalizowane liczniki ssl.*
  kubectl exec "$1" -c istio-proxy -- curl -s -G localhost:15000/stats --data-urlencode 'filter=ssl\.' 2>/dev/null \
    | grep -E '^[^ ]+: [0-9]+$' | sort > "$2" || true
}
delta_lines() { awk -F': ' 'NR==FNR{b[$1]=$2; next} {d=$2-(($1 in b)?b[$1]:0); if (d!=0) print $1": "d}' "$1" "$2"; }
sumre()       { RE="$2" awk -F': ' '$1 ~ ENVIRON["RE"] {s+=$2} END{print s+0}' "$1"; }

# ------------------------------------------------------------------ podkomendy
cmd_versions() {
  local K S
  K=$(k6_pod); S=$(srv_pod)
  [ -n "$K" ] && [ -n "$S" ] || die "brak podow k6/httpbin (najpierw: cluster)"
  {
    echo "# $(date -u +%FT%TZ)"
    echo "--- istioctl version"; istioctl version 2>&1
    echo "--- obraz sidecara (k6)"; kubectl get pod "$K" -n "$NS" -o jsonpath='{.spec.containers[?(@.name=="istio-proxy")].image}'; echo
    echo "--- envoy w sidecarze klienta"; kubectl exec "$K" -n "$NS" -c istio-proxy -- /usr/local/bin/envoy --version 2>&1 | head -3
    echo "--- envoy w sidecarze serwera"; kubectl exec "$S" -n "$NS" -c istio-proxy -- /usr/local/bin/envoy --version 2>&1 | head -3
    echo "--- pilot-agent (wersja Go)"; kubectl exec "$K" -n "$NS" -c istio-proxy -- pilot-agent version -o yaml 2>&1 | head -20
  } | tee "$OUT/versions.txt"
}

cmd_cluster() {
  command -v istioctl >/dev/null || die "brak istioctl w PATH (instrukcja w naglowku skryptu)"
  local have
  have=$(istioctl version --remote=false 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  [ "$have" = "$ISTIO_TARGET" ] || die "istioctl to $have, a potrzebny $ISTIO_TARGET"
  echo "UWAGA: to USUNIE klaster 'thesis-cluster' (a z nim wszystko, co w nim jest) i zalozy nowy na Istio $ISTIO_TARGET."
  confirm "Kontynuowac?" || die "przerwano"
  sed "s/^ISTIO_VERSION=.*/ISTIO_VERSION=\"$ISTIO_TARGET\"/" ./01_scripts/setup_cluster.sh > "$OUT/.setup_cluster_f4.sh"
  bash "$OUT/.setup_cluster_f4.sh"
}

cmd_pki() { bash ./01_scripts/f4_pki.sh; }

patch_deploy() {   # $1 = deployment, $2 = rola (server|client)
  local dep=$1 role=$2 pf
  pf=$(mktemp)
  python3 - "$role" > "$pf" <<'PY'
import json, sys
role = sys.argv[1]
algs = ["rsa", "ecdsa", "mldsa"]
vol = {f"f4-{a}": {"secret": {"secretName": f"f4-{a}-{role}"}} for a in algs}
mnt = {f"f4-{a}": {"mountPath": f"/etc/f4/{a}", "readOnly": True} for a in algs}
print(json.dumps({"spec": {"template": {"metadata": {"annotations": {
    "sidecar.istio.io/userVolume": json.dumps(vol),
    "sidecar.istio.io/userVolumeMount": json.dumps(mnt)}}}}}))
PY
  kubectl patch deployment "$dep" -n "$NS" --type merge --patch-file "$pf" || die "patch $dep nie przeszedl"
  rm -f "$pf"
}

cmd_deploy() {
  local a role
  for a in "${ALGS[@]}"; do
    for role in server client; do
      [ -f "$PKI/$a/$role.key" ] || die "brak $PKI/$a/$role.key (najpierw: pki)"
      kubectl create secret generic "f4-$a-$role" -n "$NS" \
        --from-file=tls.crt="$PKI/$a/$role.chain.pem" \
        --from-file=tls.key="$PKI/$a/$role.key" \
        --from-file=ca.crt="$PKI/$a/ca.crt" \
        --dry-run=client -o yaml | kubectl apply -f - >/dev/null || die "secret f4-$a-$role"
    done
  done
  echo "Secrety utworzone. Montuje do sidecarow (restart podow httpbin i k6)..."
  patch_deploy httpbin server
  patch_deploy k6-deploy client
  kubectl rollout status deployment/httpbin -n "$NS" --timeout=240s || die "httpbin nie wstal"
  kubectl rollout status deployment/k6-deploy -n "$NS" --timeout=240s || die "k6 nie wstal"
  local S K
  S=$(srv_pod); K=$(k6_pod)
  echo "--- zawartosc /etc/f4 w sidecarze serwera ($S)"
  kubectl exec "$S" -n "$NS" -c istio-proxy -- sh -c 'for d in /etc/f4/*; do echo "$d"; ls -lL "$d"; done' | tee "$OUT/deploy_mounts_server.txt"
  echo "--- zawartosc /etc/f4 w sidecarze klienta ($K)"
  kubectl exec "$K" -n "$NS" -c istio-proxy -- sh -c 'for d in /etc/f4/*; do echo "$d"; ls -lL "$d"; done' | tee "$OUT/deploy_mounts_client.txt"
}

diag_collect() {   # $1 = alg
  local K S
  K=$(k6_pod); S=$(srv_pod)
  echo "### /certs w sidecarze klienta (co Envoy faktycznie zaladowal)"
  kubectl exec "$K" -n "$NS" -c istio-proxy -- curl -s localhost:15000/certs 2>/dev/null \
    | jq -r '.certificates[]? | (.ca_cert[]?, .cert_chain[]?) | "\(.path // "-")  serial=\(.serial_number // "-")  waznosc_dni=\(.days_until_expiration // "-")  SAN=\([.subject_alt_names[]? | (.uri // .dns // "?")] | join(","))"' 2>&1 | head -12
  echo "### /certs w sidecarze serwera"
  kubectl exec "$S" -n "$NS" -c istio-proxy -- curl -s localhost:15000/certs 2>/dev/null \
    | jq -r '.certificates[]? | (.ca_cert[]?, .cert_chain[]?) | "\(.path // "-")  serial=\(.serial_number // "-")  waznosc_dni=\(.days_until_expiration // "-")  SAN=\([.subject_alt_names[]? | (.uri // .dns // "?")] | join(","))"' 2>&1 | head -12
  echo "### lancuchy filtrow serwera na porcie 8080 (virtualInbound)"
  istioctl proxy-config listener "$S" -n "$NS" --port 15006 -o json 2>&1 \
    | jq -r '.[]? | select(.name=="virtualInbound") | .filterChains[]? | select(.filterChainMatch.destinationPort==8080) | "nazwa=\(.name) match=\(.filterChainMatch|tojson) transport_socket=\(.transportSocket.name // "BRAK")"' 2>&1 | head -10
  echo "### klaster klienta -> httpbin (transport_socket)"
  istioctl proxy-config cluster "$K" -n "$NS" --fqdn httpbin.default.svc.cluster.local -o json 2>&1 \
    | jq '.[0] | {name, transportSocket: .transportSocket.name, tls: (.transportSocket.typedConfig | {maxSessionKeys, params: .commonTlsContext.tlsParams, certs: .commonTlsContext.tlsCertificates, ca: .commonTlsContext.validationContext.trustedCa})}' 2>&1 | head -40
  echo "### istiod: bledy EnvoyFilter (ostatnie 5 min)"
  kubectl logs -n istio-system deploy/istiod --since=5m 2>/dev/null | grep -iE 'envoyfilter|invalid|unknown field' | tail -10
  echo "### logi sidecarow (ostatnie 3 min, tylko TLS/blędy)"
  for P in "$K" "$S"; do
    echo "-- $P"
    kubectl logs "$P" -n "$NS" -c istio-proxy --since=3m 2>/dev/null | grep -iE 'error|warn|tls|ssl|secret|certificate' | grep -viE 'readiness|healthcheck' | tail -12
  done
}

SMOKE_JS="import http from 'k6/http'; import { sleep } from 'k6'; export default function () { http.get('http://httpbin.default.svc.cluster.local:8000/get'); sleep(0.05); }"

# $1 = alg (rsa|ecdsa|mldsa|native)  $2 = resumed|full ; wynik: 0 = wszystko PASS
smoke_one() {
  local alg=$1 mode=$2 K S T f k6out k6rc
  K=$(k6_pod); S=$(srv_pod)
  [ -n "$K" ] && [ -n "$S" ] || die "brak podow"
  T=$(mktemp -d)
  f="$OUT/smoke_${alg}-${mode}.txt"
  echo "=== smoke: $alg / $mode"
  if [ "$alg" = native ]; then
    apply_arm_any "native-$mode" 1 || return 1
  else
    apply_arm_f4 "$alg" "$mode" 1 || return 1
  fi
  stats_to "$K" "$T/kb"; stats_to "$S" "$T/sb"
  k6out=$(echo "$SMOKE_JS" | kubectl exec -i "$K" -n "$NS" -c k6 -- k6 run --vus 5 --duration 8s - 2>&1); k6rc=$?
  sleep 2
  stats_to "$K" "$T/ka"; stats_to "$S" "$T/sa"
  delta_lines "$T/kb" "$T/ka" > "$T/kd"; delta_lines "$T/sb" "$T/sa" > "$T/sd"

  local reqs failed hs hsc reused mlkem curves_all err sig_m sig_all
  reqs=$(echo "$k6out" | grep -E '^ *http_reqs' | grep -oE '[0-9]+' | head -1); reqs=${reqs:-0}
  failed=$(echo "$k6out" | grep -E 'http_req_failed' | grep -oE '[0-9.]+%' | head -1); failed=${failed:-?}
  hs=$(sumre "$T/sd" '\.ssl\.handshake$')
  hsc=$(sumre "$T/kd" '\.ssl\.handshake$')
  reused=$(sumre "$T/sd" '\.ssl\.session_reused$')
  mlkem=$(sumre "$T/sd" '\.ssl\.curves\.X25519MLKEM768$')
  curves_all=$(sumre "$T/sd" '\.ssl\.curves\.')
  err=$(( $(sumre "$T/sd" '\.ssl\.(connection_error|fail_verify)') + $(sumre "$T/kd" '\.ssl\.(connection_error|fail_verify)') ))
  sig_m=$(( $(sumre "$T/sd" '\.ssl\.sigalgs\.mldsa65$') + $(sumre "$T/kd" '\.ssl\.sigalgs\.mldsa65$') ))
  sig_all=$(( $(sumre "$T/sd" '\.ssl\.sigalgs\.') + $(sumre "$T/kd" '\.ssl\.sigalgs\.') ))

  local v_traffic=FAIL v_tls=FAIL v_kex=FAIL v_sig=FAIL v_err=FAIL v_res=FAIL
  [ "$k6rc" -eq 0 ] && [ "$reqs" -gt 0 ] && [ "$failed" = "0.00%" ] && v_traffic=PASS
  [ "$hs" -gt 0 ] && v_tls=PASS
  [ "$mlkem" -gt 0 ] && [ "$mlkem" -eq "$curves_all" ] && v_kex=PASS
  if [ "$alg" = mldsa ]; then
    [ "$sig_m" -gt 0 ] && v_sig=PASS
  else
    [ "$sig_m" -eq 0 ] && v_sig=PASS
  fi
  [ "$err" -eq 0 ] && v_err=PASS
  if [ "$mode" = full ]; then [ "$reused" -eq 0 ] && v_res=PASS; else [ "$reused" -gt 0 ] && v_res=PASS; fi

  {
    echo "smoke: alg=$alg mode=$mode   $(date -u +%FT%TZ)"
    echo "k6: exit=$k6rc  http_reqs=$reqs  http_req_failed=$failed"
    echo "serwer: handshake=$hs  session_reused=$reused  curves(MLKEM768/wszystkie)=$mlkem/$curves_all"
    echo "klient: handshake=$hsc"
    echo "bledy TLS (connection_error + fail_verify, oba sidecary)=$err"
    echo "sigalgs: mldsa65=$sig_m  wszystkie=$sig_all"
    echo "PASS/FAIL: traffic=$v_traffic tls_wlaczony=$v_tls kex_pq=$v_kex sigalg=$v_sig bledy=$v_err wznowienie=$v_res"
    echo "--- delta licznikow SERWER (niezerowe)"; cat "$T/sd"
    echo "--- delta licznikow KLIENT (niezerowe)"; cat "$T/kd"
    echo "--- wyjscie k6 (skrot)"; echo "$k6out" | grep -E 'http_reqs|http_req_failed|http_req_duration|checks|ERRO|WARN' | head -12
  } > "$f"
  if [ "$mode" = full ] || [ "${DIAG:-0}" = 1 ]; then
    { echo; echo "================ DIAGNOSTYKA"; diag_collect "$alg"; } >> "$f" 2>&1
  fi
  sed -n '1,8p' "$f"
  rm -rf "$T"
  [ "$v_traffic$v_tls$v_kex$v_sig$v_err$v_res" = PASSPASSPASSPASSPASSPASS ]
}

cmd_smoke() {
  local which=${1:-all} fails=0 a m list
  [ -n "$(kubectl get secret f4-mldsa-server -n "$NS" -o name 2>/dev/null)" ] || die "brak Secretow f4-* (najpierw: deploy)"
  if [ "$which" = all ]; then list="native rsa ecdsa mldsa"; else list=$which; fi
  for a in $list; do
    for m in full resumed; do
      smoke_one "$a" "$m" || fails=$((fails+1))
    done
  done
  cleanup_mesh_config
  echo
  echo "Szczegoly: $OUT/smoke_*.txt   (FAIL-e: $fails)"
  [ "$fails" -eq 0 ]
}

cmd_sdscheck() {
  local K a f="$OUT/sdscheck.txt"
  K=$(k6_pod)
  : > "$f"
  for a in rsa mldsa; do
    cleanup_mesh_config
    kubectl apply -f - >/dev/null <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: f4-sdscheck
  namespace: ${NS}
spec:
  host: httpbin.default.svc.cluster.local
  trafficPolicy:
    tls:
      mode: MUTUAL
      clientCertificate: /etc/f4/${a}/tls.crt
      privateKey: /etc/f4/${a}/tls.key
      caCertificates: /etc/f4/${a}/ca.crt
EOF
    sleep 20
    {
      echo "=================== DestinationRule MUTUAL z plikami f4/$a (sciezka przez pilot-agent/SDS)"
      echo "--- istioctl proxy-config secret (klient)"
      istioctl proxy-config secret "$K" -n "$NS" 2>&1 | head -12
      echo "--- log pilot-agenta (klient), ostatnie 3 min"
      kubectl logs "$K" -n "$NS" -c istio-proxy --since=3m 2>/dev/null | grep -E 'file-cert|file-root|/etc/f4|failed to generate secret|read certificate from file' | tail -8
    } | tee -a "$f"
    kubectl delete destinationrule f4-sdscheck -n "$NS" >/dev/null 2>&1 || true
  done
  cleanup_mesh_config
  echo
  echo "Oczekiwanie: rsa -> 'read certificate from file' / ACTIVE; mldsa -> 'failed to generate secret ... from file' (tls: failed to parse private key)."
  echo "Wynik: $f"
}

# ------------------------------------------------------------------ bench (wstępne F4)
bench_counts() {   # pod -> "mldsa65 wszystkie_sigalgs" (liczniki skumulowane)
  local T; T=$(mktemp)
  stats_to "$1" "$T"
  echo "$(sumre "$T" '\.ssl\.sigalgs\.mldsa65$') $(sumre "$T" '\.ssl\.sigalgs\.')"
  rm -f "$T"
}

cmd_bench() {
  local ARMS_LIST=${ARMS:-"native-resumed native-full f4-rsa-resumed f4-rsa-full f4-ecdsa-resumed f4-ecdsa-full f4-mldsa-resumed f4-mldsa-full"}
  local N_RUNS=${N_RUNS:-2} DURATION=${DURATION:-60} WARM_S=${WARM_S:-10} COOL_S=${COOL_S:-5}
  local COOLDOWN_S=${COOLDOWN_S:-10} SETTLE_S=${SETTLE_S:-20} RATES=${RATES:-100} MRPCS=${MRPCS:-"1 0"} SESSION=${SESSION:-1}
  local STEADY_S=$(( DURATION - WARM_S - COOL_S ))
  local K6_SCRIPT=./03_test_scripts/main_k6_scenarios.js
  local CSV=$OUT/sweeps.csv
  local K6_POD HTTPBIN_POD
  K6_POD=$(k6_pod); HTTPBIN_POD=$(srv_pod)
  [ -n "$K6_POD" ] && [ -n "$HTTPBIN_POD" ] || die "brak podow"
  [ -n "$(kubectl get secret f4-mldsa-server -n "$NS" -o name 2>/dev/null)" ] || die "brak Secretow f4-* (najpierw: deploy)"
  ./01_scripts/record_env.sh "$OUT/environment_bench_$(date +%Y%m%d_%H%M%S).txt" || true
  if [ "${QUIET:-1}" = 1 ]; then ./01_scripts/quiet_mode.sh on; fi
  trap 'cleanup_mesh_config; [ "${QUIET:-1}" = 1 ] && ./01_scripts/quiet_mode.sh off' EXIT

  if [ ! -f "$CSV" ]; then
    echo "mode,setup,rate_target,mrpc,fraction,run,window_rps,k6_rps,p50_ms,p95_ms,p99_ms,fail_rate,dropped_iters,client_sidecar_cpu,server_sidecar_cpu,handshakes,handshakes_per_s,session_reused,conn_errors,cpu_per_req_us,cpu_per_handshake_us,netem_rtt_ms,netem_loss_pct,cert_key,timestamp,session,calib_ms,arm,sig_mldsa65,sig_all,verdict" > "$CSV"
  fi

  warmup() {
    kubectl exec -i "$K6_POD" -c k6 -- k6 run -e TEST_TYPE=handshake -e RATE=50 -e DURATION=20s - < "$K6_SCRIPT" >/dev/null 2>&1 || true
    sleep "$SETTLE_S"
  }

  one_point() {
    local arm=$1 rate=$2 mrpc=$3 run=$4 calib summary k6_rps p50 p95 p99 fail dropped
    local c0m c0a s0m s0a c1 s1 c1m c1a s1m s1a sig_m sig_all verdict=OK why=""
    calib=$(calib_ms)
    read -r c0m c0a <<< "$c0"; read -r s0m s0a <<< "$s0"
    measure_window "$K6_POD" "$HTTPBIN_POD" "$WARM_S" "$STEADY_S" "$K6_SCRIPT" \
      -e TEST_TYPE=handshake -e RATE="$rate" -e DURATION="${DURATION}s"
    summary=$(kubectl exec "$K6_POD" -c k6 -- cat /tmp/summary.json 2>/dev/null || echo '{"metrics":{}}')
    k6_rps=$(echo "$summary"  | jq -r '.metrics.http_reqs.values.rate // ""')
    p50=$(echo "$summary"     | jq -r '.metrics.http_req_duration.values.med // ""')
    p95=$(echo "$summary"     | jq -r '.metrics.http_req_duration.values["p(95)"] // ""')
    p99=$(echo "$summary"     | jq -r '.metrics.http_req_duration.values["p(99)"] // ""')
    fail=$(echo "$summary"    | jq -r '.metrics.http_req_failed.values.rate // 0')
    dropped=$(echo "$summary" | jq -r '.metrics.dropped_iterations.values.count // 0')
    c1=$(bench_counts "$K6_POD"); s1=$(bench_counts "$HTTPBIN_POD")
    read -r c1m c1a <<< "$c1"; read -r s1m s1a <<< "$s1"
    sig_m=$(( (c1m - c0m) + (s1m - s0m) )); sig_all=$(( (c1a - c0a) + (s1a - s0a) ))

    # dowody: KEX = tylko X25519MLKEM768, brak bledow, algorytm podpisu zgodny z ramieniem, wznowienia zgodne z trybem
    if [ "$W_HS" -le 0 ] && [ "$mrpc" != 0 ]; then verdict=FAIL; why="$why no_handshakes"; fi
    if [ "$W_HS" -gt 0 ] && { [ "$W_CURVE_MLKEM" -ne "$W_CURVE_ALL" ] || [ "$W_CURVE_MLKEM" -le 0 ]; }; then verdict=FAIL; why="$why kex"; fi
    [ "$W_ERRORS" -ne 0 ] && { verdict=FAIL; why="$why errors"; }
    case $arm in
      f4-mldsa-*) [ "$sig_m" -le 0 ] && { verdict=FAIL; why="$why no_mldsa_sig"; } ;;
      *)          [ "$sig_m" -ne 0 ] && { verdict=FAIL; why="$why unexpected_mldsa_sig"; } ;;
    esac
    case $arm in
      *-full) [ "$W_REUSED" -ne 0 ] && { verdict=FAIL; why="$why reused_in_full"; } ;;
      *-resumed) [ "$mrpc" != 0 ] && [ "$W_REUSED" -le 0 ] && { verdict=FAIL; why="$why no_reuse"; } ;;
    esac
    [ "$verdict" = FAIL ] && verdict="FAIL:${why# }"

    echo "grid,$arm,$rate,$mrpc,0,$run,$W_RPS,$k6_rps,$p50,$p95,$p99,$fail,$dropped,$W_CLIENT_CPU,$W_SERVER_CPU,$W_HS,$W_HS_PER_S,$W_REUSED,$W_ERRORS,$W_CPU_PER_REQ_US,$W_CPU_PER_HS_US,0,0,$(arm_alg "$arm"),$(date -u +%FT%TZ),$SESSION,$calib,$arm,$sig_m,$sig_all,$verdict" >> "$CSV"
    echo "    rps=$W_RPS p99=$p99 cpu/req=${W_CPU_PER_REQ_US}us hs/s=$W_HS_PER_S reused=$W_REUSED err=$W_ERRORS sig_mldsa=$sig_m  [$verdict]"
    sleep "$COOLDOWN_S"
  }

  local RUN RATE M ARM c0 s0
  for RUN in $(seq 1 "$N_RUNS"); do
    for RATE in $(printf "%s\n" $RATES | shuf); do
      for M in $(printf "%s\n" $MRPCS | shuf); do
        for ARM in $(printf "%s\n" $ARMS_LIST | shuf); do
          echo "--- [bench] $ARM rate=$RATE mrpc=$M run=$RUN"
          apply_arm_any "$ARM" "$M" || { echo "    pominieto: nie udalo sie wlaczyc ramienia"; continue; }
          c0=$(bench_counts "$K6_POD"); s0=$(bench_counts "$HTTPBIN_POD")
          warmup
          one_point "$ARM" "$RATE" "$M" "$RUN"
        done
      done
    done
  done
  echo "Gotowe: $CSV"
}

cmd_cleanup() { cleanup_mesh_config; echo "EnvoyFiltry, PeerAuthentication i DestinationRule usuniete."; }

case "${1:-}" in
  versions) cmd_versions ;;
  cluster)  cmd_cluster ;;
  pki)      cmd_pki ;;
  deploy)   cmd_deploy ;;
  smoke)    cmd_smoke "${2:-all}" ;;
  sdscheck) cmd_sdscheck ;;
  bench)    cmd_bench ;;
  cleanup)  cmd_cleanup ;;
  render)   render_ef "${2:-mldsa}" "${3:-full}" ;;   # tylko wypisuje EnvoyFiltry (do podgladu)
  *) sed -n '2,28p' "$0" ;;
esac
