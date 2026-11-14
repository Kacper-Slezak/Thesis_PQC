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
