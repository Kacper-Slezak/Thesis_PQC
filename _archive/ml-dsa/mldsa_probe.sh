#!/usr/bin/env bash
# mldsa_probe.sh – czy Envoy z Istio przyjmie certyfikaty ML-DSA?
#
# Uruchamiaj po kolei (każdy krok zapisuje wynik do ./mldsa_probe_out/):
#   ./mldsa_probe.sh 0            # wersja Envoya w obrazie istio-proxy
#   ./mldsa_probe.sh 1            # czy binarka w ogóle zawiera napisy ML-DSA
#   ./mldsa_probe.sh 2            # generuje certyfikaty: ML-DSA-65 i kontrolne RSA-2048
#   ./mldsa_probe.sh 3 rsa        # dwa Envoye (klient -> TLS -> serwer) z RSA   = KONTROLA
#   ./mldsa_probe.sh 3 mldsa      # to samo z ML-DSA-65                          = TEST
#   ./mldsa_probe.sh 4            # mikrobenchmark podpisów: RSA-2048 vs ML-DSA
#   ./mldsa_probe.sh 5            # diagnoza: serwer RSA, ale klient ufa CA z ML-DSA
#   ./mldsa_probe.sh 6            # konwertuje klucz serwera ML-DSA do formy seed-only (wymaga jej BoringSSL)
#   LOGLVL=debug ./mldsa_probe.sh 3 mldsa   # to samo co krok 3, ale z logami TLS (plik step3_mldsa_debug.txt)
#   ./mldsa_probe.sh 7 [rsa]      # kontrola: serwer Envoya + klient openssl s_client (OpenSSL 3.5); 'rsa' = porównanie rozmiaru
#   ./mldsa_probe.sh 8 [nazwa]    # klient Envoya z wymuszonym tls_params.signature_algorithms (domyślnie mldsa65)
#   IMG=envoyproxy/envoy:dev ./mldsa_probe.sh 3 mldsa   # ten sam test na świeższym, upstreamowym Envoyu
#                                                       # (zmienna IMG ma pierwszeństwo przed image.txt)
#
# Pliki wynikowe kroków 0, 3, 7, 8 mają w nazwie tag obrazu (np. ..._istio_proxyv2_1.31.4.txt), więc kolejne obrazy się nie nadpisują.
# Wymaga: docker (WSL2). kubectl jest opcjonalny (tylko do odczytu obrazu istio-proxy z klastra).
# Nic nie dotyka klastra ani repo; wszystko dzieje się w kontenerach i w katalogu wyjściowym.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${OUT:-$HERE/mldsa_probe_out}
mkdir -p "$OUT"
cd "$OUT" || exit 1

imgtag() { echo "${IMG:-img}" | tr '/:' '__'; }

get_img() {
  if [ -n "${IMG:-}" ]; then return; fi
  if [ -f image.txt ]; then IMG=$(cat image.txt); return; fi
  IMG=$(kubectl get pod -l app=httpbin -o jsonpath='{..image}' 2>/dev/null | tr ' ' '\n' | grep proxyv2 | head -1)
  IMG=${IMG:-docker.io/istio/proxyv2:1.30.2}
  echo "$IMG" > image.txt
}

step0() {
  get_img
  echo "Obraz istio-proxy: $IMG"
  docker pull -q "$IMG" > /dev/null
  docker run --rm --entrypoint /usr/local/bin/envoy "$IMG" --version | tee "step0_envoy_version_$(imgtag).txt"
}

step1() {
  get_img
  docker rm -f mldsa_px > /dev/null 2>&1
  docker create --name mldsa_px "$IMG" > /dev/null
  docker cp mldsa_px:/usr/local/bin/envoy ./envoy.bin
  docker rm mldsa_px > /dev/null
  ls -lh envoy.bin
  echo "--- napisy w binarce (kontrola: X25519MLKEM768 musi się pojawić) ---"
  LC_ALL=C grep -a -o -i -E 'X25519MLKEM768|ML-?DSA-?[0-9]*' envoy.bin | sort | uniq -c | sort -rn | head -20 | tee step1_strings.txt
  echo
  echo "Brak trafień ML-DSA = ta wersja BoringSSL w Envoyu raczej go nie ma (stop, to też wynik)."
  echo "Trafienia = tylko wskazówka (mogą pochodzić z samych prymitywów), prawdę pokaże krok 3."
}

step2() {
  FMT=${1:-default}   # 'seedonly' = klucz ML-DSA zapisany jako sam seed (RFC 9881)
  cat > gen_pki.sh <<'EOF'
set -e
apk add -q --no-cache openssl
openssl version
case "$(openssl version | cut -d' ' -f2)" in
  3.[5-9]*|[4-9].*) ;;
  *) echo "BLAD: potrzebny OpenSSL >= 3.5"; exit 1 ;;
esac
cat > ca.cnf <<CNF
[req]
distinguished_name = dn
x509_extensions = v3
prompt = no
[dn]
CN = probe-ca
[v3]
basicConstraints = critical,CA:TRUE
keyUsage = critical,keyCertSign,cRLSign
subjectKeyIdentifier = hash
CNF
printf 'subjectAltName=DNS:localhost\nkeyUsage=critical,digitalSignature\nextendedKeyUsage=serverAuth\n' > srv.ext
for A in rsa mldsa; do
  if [ "$A" = mldsa ]; then
    GEN="openssl genpkey -algorithm ML-DSA-65 $EXTRA"
  else
    GEN="openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048"
  fi
  $GEN -out ${A}_ca.key
  openssl req -x509 -new -config ca.cnf -key ${A}_ca.key -days 7 -out ${A}_ca.crt
  $GEN -out ${A}_srv.key
  openssl req -new -key ${A}_srv.key -subj "/CN=localhost" -out ${A}_srv.csr
  openssl x509 -req -in ${A}_srv.csr -CA ${A}_ca.crt -CAkey ${A}_ca.key -CAcreateserial \
          -days 7 -extfile srv.ext -out ${A}_srv.crt
  echo "== $A"
  openssl verify -CAfile ${A}_ca.crt ${A}_srv.crt
  openssl x509 -in ${A}_srv.crt -noout -text | grep -E 'Signature Algorithm|Public Key Algorithm' | sort -u
  ls -l ${A}_srv.crt ${A}_srv.key | awk '{print $5, $9}'
done
chown -R "$UG" /w
EOF
  EXTRA=""
  [ "$FMT" = seedonly ] && EXTRA="-provparam ml-dsa.output_formats=seed-only"
  docker run --rm -v "$PWD:/w" -w /w -e UG="$(id -u):$(id -g)" -e EXTRA="$EXTRA" \
    alpine:latest sh /w/gen_pki.sh 2>&1 | tee step2_pki.txt
}

write_configs() {
  cat > server.tpl.yaml <<'EOF'
admin:
  address: {socket_address: {address: 127.0.0.1, port_value: 19901}}
static_resources:
  listeners:
  - name: tls_in
    address: {socket_address: {address: 127.0.0.1, port_value: 18443}}
    filter_chains:
    - transport_socket:
        name: envoy.transport_sockets.tls
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
          common_tls_context:
            tls_params:
              tls_minimum_protocol_version: TLSv1_3
              tls_maximum_protocol_version: TLSv1_3
              ecdh_curves: ["X25519MLKEM768", "X25519"]
            tls_certificates:
            - certificate_chain: {filename: /w/@PKI@_srv.crt}
              private_key: {filename: /w/@PKI@_srv.key}
      filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: srv
          route_config:
            virtual_hosts:
            - name: all
              domains: ["*"]
              routes:
              - match: {prefix: "/"}
                direct_response: {status: 200, body: {inline_string: "ok\n"}}
          http_filters:
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
EOF
  cat > client.tpl.yaml <<'EOF'
admin:
  address: {socket_address: {address: 127.0.0.1, port_value: 19902}}
static_resources:
  listeners:
  - name: plain_in
    address: {socket_address: {address: 127.0.0.1, port_value: 18080}}
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: cli
          route_config:
            virtual_hosts:
            - name: all
              domains: ["*"]
              routes:
              - match: {prefix: "/"}
                route: {cluster: pq_srv}
          http_filters:
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
  clusters:
  - name: pq_srv
    type: STATIC
    connect_timeout: 2s
    load_assignment:
      cluster_name: pq_srv
      endpoints:
      - lb_endpoints:
        - endpoint:
            address: {socket_address: {address: 127.0.0.1, port_value: 18443}}
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        sni: localhost
        common_tls_context:
          tls_params:
            tls_minimum_protocol_version: TLSv1_3
            tls_maximum_protocol_version: TLSv1_3
            ecdh_curves: ["X25519MLKEM768", "X25519"]
          validation_context:
            trusted_ca: {filename: /w/@PKI@_ca.crt}
            match_typed_subject_alt_names:
            - san_type: DNS
              matcher: {exact: localhost}
EOF
  cat > run_pair.sh <<'EOF'
E=/usr/local/bin/envoy
# get host:port /sciezka  (curl, a gdy go brak: wget albo bash /dev/tcp – np. w obrazie envoyproxy/envoy)
get() {
  if command -v curl >/dev/null 2>&1; then curl -s -m 5 "http://$1$2"
  elif command -v wget >/dev/null 2>&1; then wget -q -T 5 -O - "http://$1$2"
  elif command -v bash >/dev/null 2>&1; then
    bash -c "exec 3<>/dev/tcp/${1%:*}/${1#*:}; printf 'GET $2 HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n' >&3; cat <&3"
  else echo "brak curl/wget/bash w obrazie"; fi
}
LL=${LOGLVL:-warning}
$E -c /w/server_$PKI.yaml --base-id 21 --disable-hot-restart -l $LL > /tmp/srv.log 2>&1 &
$E -c /w/client_$PKI.yaml --base-id 22 --disable-hot-restart -l $LL > /tmp/cli.log 2>&1 &
sleep 5
echo "== krok 1: czy oba Envoye żyją? (powinny być dwa razy LIVE)"
get 127.0.0.1:19901 /ready; get 127.0.0.1:19902 /ready
echo "== krok 2: żądanie przez klienta (HTTP -> TLS -> serwer)"
if command -v curl >/dev/null 2>&1; then curl -s -m 5 -w '\nHTTP %{http_code}\n' http://127.0.0.1:18080/; else get 127.0.0.1:18080 /; fi
echo "== statystyki TLS serwera (tylko niezerowe)"
get 127.0.0.1:19901 /stats | grep -E 'ssl\.(handshake|connection_error|fail_verify|sigalgs|curves|versions)' | grep -v ': 0$'
echo "== statystyki TLS klienta (tylko niezerowe)"
get 127.0.0.1:19902 /stats | grep -E 'ssl\.(handshake|connection_error|fail_verify|sigalgs|curves|versions)' | grep -v ': 0$'
echo "== logi (pierwsze linie)"
head -n 4 /tmp/srv.log; head -n 4 /tmp/cli.log
echo "== krytyczne błędy / odmowy startu (jeśli są)"
grep -i -E 'critical|\[error\]|failed to|unsupported|unknown' /tmp/srv.log /tmp/cli.log | head -n 10
echo "== logi serwera: linie o TLS/SSL (sensowne przy LOGLVL=debug)"
grep -i -E 'ssl error|tls error|handshake|alert|sigalg|signature|certificate' /tmp/srv.log | head -n 25
echo "== logi klienta: linie o TLS/SSL"
grep -i -E 'ssl error|tls error|handshake|alert|sigalg|signature|certificate' /tmp/cli.log | head -n 25
EOF
}

step3() {
  PKI=${1:-}
  case "$PKI" in rsa|mldsa) ;; *) echo "Uzycie: $0 3 rsa|mldsa"; exit 1 ;; esac
  [ -f "${PKI}_srv.crt" ] || { echo "Najpierw krok 2 (brak ${PKI}_srv.crt)"; exit 1; }
  get_img
  write_configs
  sed "s/@PKI@/$PKI/g" server.tpl.yaml > "server_$PKI.yaml"
  sed "s/@PKI@/$PKI/g" client.tpl.yaml > "client_$PKI.yaml"
  # LOGLVL=debug => dodatkowe logi TLS; wynik trafia do step3_<pki>_debug.txt (nie nadpisuje zwykłego)
  docker run --rm -v "$PWD:/w:ro" -e PKI="$PKI" -e LOGLVL="${LOGLVL:-warning}" --entrypoint /bin/sh "$IMG" /w/run_pair.sh 2>&1 \
    | tee "step3_${PKI}${LOGLVL:+_$LOGLVL}_$(imgtag).txt"
}

step4() {
  docker run --rm alpine:latest sh -c '
    apk add -q --no-cache openssl
    openssl version
    for A in rsa2048 ecdsap256 ed25519 mldsa65 ML-DSA-44 ML-DSA-65 ML-DSA-87; do
      echo "== $A"
      openssl speed -seconds 3 $A 2>&1 | tail -n 4
    done
    echo "== nazwy algorytmów znane przez speed (dsa/kem):"
    openssl speed -help 2>&1 | grep -i -E "dsa|kem" | head -n 20' | tee step4_speed.txt
  echo
  echo "Jeśli przy ML-DSA-* jest 'Unknown algorithm', ta wersja 'openssl speed' nie zna ML-DSA (wklej mi ostatnią sekcję)."
}

# Diagnoza po nieudanym kroku 3 mldsa: serwer ma zwykły RSA, a klient ufa CA z ML-DSA.
#  - klient nie startuje i loguje błąd wczytania CA  = parser certyfikatów Envoya odrzuca ML-DSA w ogóle
#  - klient startuje, a żądanie kończy się 503 / fail_verify_error = certyfikat ML-DSA się wczytuje,
#    a odrzucony jest dopiero jako certyfikat serwera (klucz ML-DSA w SSL_CTX)
step5() {
  [ -f mldsa_ca.crt ] && [ -f rsa_srv.crt ] || { echo "Najpierw krok 2"; exit 1; }
  get_img
  write_configs
  sed "s/@PKI@/rsa/g" server.tpl.yaml > server_x.yaml
  sed "s/@PKI@_ca.crt/mldsa_ca.crt/; s/@PKI@/rsa/g" client.tpl.yaml > client_x.yaml
  docker run --rm -v "$PWD:/w:ro" -e PKI=x --entrypoint /bin/sh "$IMG" /w/run_pair.sh 2>&1 | tee step5_diag.txt
}

# Krok 6: BoringSSL (a więc Envoy) czyta klucz prywatny ML-DSA tylko w formie "seed" (RFC 9881).
# OpenSSL 3.5 zapisuje domyślnie "seed-priv" (seed + klucz rozwinięty, ~5,6 KB w PEM).
# Konwertujemy istniejący mldsa_srv.key do seed-only; certyfikat zostaje ten sam (ten sam seed => ten sam klucz publiczny).
step6() {
  [ -f mldsa_srv.key ] && [ -f mldsa_srv.crt ] || { echo "Najpierw krok 2"; exit 1; }
  cp -n mldsa_srv.key mldsa_srv.key.seed_priv.orig
  cat > fix_key.sh <<'EOF'
set -e
apk add -q --no-cache openssl
openssl version
openssl pkey -provparam ml-dsa.output_formats=seed-only -in mldsa_srv.key.seed_priv.orig -out mldsa_srv.key
echo "rozmiar klucza przed/po (B):"
ls -l mldsa_srv.key.seed_priv.orig mldsa_srv.key | awk '{print $5, $9}'
echo "kontrola: klucz publiczny z klucza prywatnego == klucz publiczny z certyfikatu?"
A=$(openssl pkey -in mldsa_srv.key -pubout | openssl sha256)
B=$(openssl x509 -in mldsa_srv.crt -noout -pubkey | openssl sha256)
echo "$A"; echo "$B"
[ "$A" = "$B" ] && echo "ZGODNE" || echo "NIEZGODNE"
chown "$UG" mldsa_srv.key
EOF
  docker run --rm -v "$PWD:/w" -w /w -e UG="$(id -u):$(id -g)" alpine:latest sh /w/fix_key.sh 2>&1 | tee step6_key.txt
  echo
  echo "Klucz po konwersji powinien mieć rzędu 200-300 B (było ~5600 B). Potem: IMG=envoyproxy/envoy:dev ./mldsa_probe.sh 3 mldsa"
}

# Krok 7: kontrola niezależna od klienta Envoya. Serwerowy Envoy (cert z $PKI) działa w tle w kontenerze,
# a klientem jest `openssl s_client` z OpenSSL 3.5 (zna ML-DSA w TLS 1.3) w tej samej sieci kontenera.
#   ./mldsa_probe.sh 7          # ML-DSA (domyślnie)  -> step7_sclient_mldsa.txt
#   ./mldsa_probe.sh 7 rsa      # kontrola RSA, do porównania rozmiaru handshake'u -> step7_sclient_rsa.txt
# W wyniku szukaj: "Peer signature type", "Verification", "SSL handshake has read N bytes".
step7() {
  PKI=${1:-mldsa}
  case "$PKI" in rsa|mldsa) ;; *) echo "Uzycie: $0 7 [rsa|mldsa]"; exit 1 ;; esac
  [ -f "${PKI}_srv.crt" ] && [ -f "${PKI}_ca.crt" ] || { echo "Najpierw krok 2 (i 6)"; exit 1; }
  get_img
  write_configs
  sed "s/@PKI@/$PKI/g" server.tpl.yaml > "server_$PKI.yaml"
  docker rm -f probe_srv >/dev/null 2>&1
  docker run -d --rm --name probe_srv -v "$PWD:/w:ro" --entrypoint /usr/local/bin/envoy "$IMG" \
    -c "/w/server_$PKI.yaml" --base-id 21 --disable-hot-restart -l debug >/dev/null
  sleep 5
  echo "== serwer Envoy żyje? (docker ps)"; docker ps --filter name=probe_srv --format '{{.Names}} {{.Status}}'
  cat > sclient.sh <<'EOF'
apk add -q --no-cache openssl
openssl version
run() {
  echo "================ s_client $*"
  # pełny wynik bez bloku PEM (inaczej head ucina podsumowanie handshake'u)
  openssl s_client -connect 127.0.0.1:18443 -tls1_3 -servername localhost -CAfile /w/${PKI}_ca.crt "$@" </dev/null 2>&1 \
    | sed '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/d' | head -n 70
}
run
[ "$PKI" = mldsa ] && run -sigalgs mldsa65
echo "================ s_client -brief"
openssl s_client -brief -connect 127.0.0.1:18443 -tls1_3 -servername localhost -CAfile /w/${PKI}_ca.crt </dev/null 2>&1 | head -n 20
EOF
  docker run --rm --network container:probe_srv -e PKI="$PKI" -v "$PWD:/w:ro" alpine:latest sh /w/sclient.sh 2>&1 | tee "step7_sclient_${PKI}_$(imgtag).txt"
  echo "================ log serwera Envoya (błędy TLS, jeśli były)" | tee -a "step7_sclient_${PKI}_$(imgtag).txt"
  docker logs probe_srv 2>&1 | grep -i -E 'TLS_error|critical|\[error\]' | head -n 25 | tee -a "step7_sclient_${PKI}_$(imgtag).txt"
  docker stop probe_srv >/dev/null 2>&1
}

# Krok 8: czy da się wymusić ofertę ML-DSA po stronie KLIENTA Envoya? Wstawia do klienta
#   tls_params.signature_algorithms: ["<nazwa>"]   (domyślnie mldsa65; nazwa spoza tabeli Envoya
#   zapewne zakończy się błędem konfiguracji - to też jest wynik). Logi na poziomie debug.
#   ./mldsa_probe.sh 8 [nazwa]  -> step8_sigalg_<nazwa>_<obraz>.txt
step8() {
  NAME=${1:-mldsa65}
  [ -f mldsa_srv.crt ] && [ -f mldsa_ca.crt ] || { echo "Najpierw krok 2 (i 6)"; exit 1; }
  get_img
  write_configs
  sed "s/@PKI@/mldsa/g" server.tpl.yaml > server_sig.yaml
  sed "s/@PKI@/mldsa/g" client.tpl.yaml \
    | sed "s/^\( *\)ecdh_curves: \[\"X25519MLKEM768\", \"X25519\"\]\$/&\n\1signature_algorithms: [\"$NAME\"]/" > client_sig.yaml
  grep -n signature_algorithms client_sig.yaml || { echo "Nie udało się wstawić signature_algorithms"; exit 1; }
  docker run --rm -v "$PWD:/w:ro" -e PKI=sig -e LOGLVL=debug --entrypoint /bin/sh "$IMG" /w/run_pair.sh 2>&1 \
    | tee "step8_sigalg_${NAME}_$(imgtag).txt"
}

case "${1:-}" in
  0) step0 ;;
  1) step1 ;;
  2) step2 "${2:-default}" ;;
  3) step3 "${2:-}" ;;
  4) step4 ;;
  5) step5 ;;
  6) step6 ;;
  7) step7 "${2:-mldsa}" ;;
  8) step8 "${2:-mldsa65}" ;;
  *) sed -n '2,28p' "$0" ;;
esac