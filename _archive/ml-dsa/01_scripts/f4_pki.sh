#!/usr/bin/env bash
# f4_pki.sh – PKI do F4: dla każdego algorytmu osobny łańcuch: root CA -> certyfikat serwera + certyfikat klienta.
#
#   rsa    RSA-2048 (kontrola, jak w F3)
#   ecdsa  ECDSA P-256 (klasyczna alternatywa, mały podpis)
#   mldsa  ML-DSA-65 (FIPS 204, RFC 9881)
#
# Wymaga: docker (OpenSSL 3.5 bierzemy z obrazu alpine; OpenSSL z WSL zwykle jest za stary na ML-DSA).
# Uruchamiaj z dowolnego miejsca; wynik trafia do ./f4_pki/<alg>/ w katalogu głównym repo:
#   ca.crt  server.crt server.key server.chain.pem  client.crt client.key client.chain.pem
# Plik *.chain.pem = certyfikat liścia (+ CA, jeśli SEND_ROOT=1). Tego używa f4_proto.sh jako tls.crt.
# Klucze ML-DSA są zapisane w formie "seed-only" (BoringSSL w Envoyu czyta tylko ją; patrz mldsa_probe.sh krok 6).
#
# Zmienne (opcjonalne):
#   ALGS="rsa ecdsa mldsa"   które algorytmy
#   DAYS=90                  ważność certyfikatów
#   SEND_ROOT=0|1            1 = serwer/klient wysyła też certyfikat CA (jak istiod: liść + root); 0 = tylko liść
#   SAN_SERVER / SAN_CLIENT  URI SAN (domyślnie tożsamości SPIFFE kont usług httpbin i default, jak w Istio)
#   NO_DOCKER=1              uruchom skrypt generujący lokalnie (wymaga openssl >= 3.5; do testów)
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT=${OUT:-$ROOT/f4_pki}
mkdir -p "$OUT"

cat > "$OUT/gen.sh" <<'EOF'
set -eu
ALGS=${ALGS:-"rsa ecdsa mldsa"}
DAYS=${DAYS:-90}
SEND_ROOT=${SEND_ROOT:-0}
SAN_SERVER=${SAN_SERVER:-spiffe://cluster.local/ns/default/sa/httpbin}
SAN_CLIENT=${SAN_CLIENT:-spiffe://cluster.local/ns/default/sa/default}
W=${W:-/w}
cd "$W"
openssl version
case "$ALGS" in
  *mldsa*)
    case "$(openssl version | cut -d' ' -f2)" in
      3.[5-9]*|[4-9].*) ;;
      *) echo "BLAD: ML-DSA wymaga OpenSSL >= 3.5"; exit 1 ;;
    esac ;;
esac

cat > ca.cnf <<CNF
[req]
distinguished_name = dn
x509_extensions = v3
prompt = no
[dn]
O = f4
CN = f4-root-ca
[v3]
basicConstraints = critical,CA:TRUE
keyUsage = critical,keyCertSign,cRLSign
subjectKeyIdentifier = hash
CNF

genkey() {   # $1 = alg, $2 = plik wyjsciowy
  case "$1" in
    rsa)   openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out "$2" ;;
    ecdsa) openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -pkeyopt ec_param_enc:named_curve -out "$2" ;;
    mldsa) openssl genpkey -algorithm ML-DSA-65 -out "$2" ;;
    *) echo "nieznany algorytm $1"; exit 1 ;;
  esac
}

leaf() {     # $1 = alg, $2 = rola (server|client), $3 = SAN URI
  A=$1; R=$2; SAN=$3
  genkey "$A" "$A/$R.key"
  printf 'subjectAltName=URI:%s\nbasicConstraints=CA:FALSE\nkeyUsage=critical,digitalSignature\nextendedKeyUsage=serverAuth,clientAuth\n' "$SAN" > "$A/$R.ext"
  openssl req -new -key "$A/$R.key" -subj "/O=f4/CN=$R" -out "$A/$R.csr"
  openssl x509 -req -in "$A/$R.csr" -CA "$A/ca.crt" -CAkey "$A/ca.key" -CAcreateserial \
          -days "$DAYS" -extfile "$A/$R.ext" -out "$A/$R.crt"
  if [ "$A" = mldsa ]; then
    # domyslny zapis OpenSSL 3.5 = seed + klucz rozwiniety (5604 B); BoringSSL przyjmuje tylko sam seed
    openssl pkey -provparam ml-dsa.output_formats=seed-only -in "$A/$R.key" -out "$A/$R.key.seed"
    mv "$A/$R.key.seed" "$A/$R.key"
  fi
  # klucz musi pasowac do certyfikatu
  K=$(openssl pkey -in "$A/$R.key" -pubout | sha256sum | cut -d' ' -f1)
  C=$(openssl x509 -in "$A/$R.crt" -pubkey -noout | sha256sum | cut -d' ' -f1)
  [ "$K" = "$C" ] || { echo "BLAD: klucz $A/$R.key nie pasuje do certyfikatu"; exit 1; }
  cp "$A/$R.crt" "$A/$R.chain.pem"
  [ "$SEND_ROOT" = 1 ] && cat "$A/ca.crt" >> "$A/$R.chain.pem"
  rm -f "$A/$R.csr" "$A/$R.ext"
}

: > summary.txt
for A in $ALGS; do
  rm -rf "$A"; mkdir -p "$A"
  genkey "$A" "$A/ca.key"
  openssl req -x509 -new -config ca.cnf -key "$A/ca.key" -days "$DAYS" -out "$A/ca.crt"
  leaf "$A" server "$SAN_SERVER"
  leaf "$A" client "$SAN_CLIENT"
  openssl verify -CAfile "$A/ca.crt" "$A/server.crt" "$A/client.crt"
  rm -f "$A/ca.srl"
  {
    echo "== $A  (SEND_ROOT=$SEND_ROOT)"
    openssl x509 -in "$A/server.crt" -noout -text | grep -E 'Signature Algorithm|Public Key Algorithm' | sort -u
    for F in ca.crt server.crt server.key server.chain.pem client.crt client.key client.chain.pem; do
      printf '  %-18s %6s B\n' "$F" "$(wc -c < "$A/$F")"
    done
    echo "  DER server.crt: $(openssl x509 -in "$A/server.crt" -outform DER | wc -c) B"
  } | tee -a summary.txt
done
rm -f ca.cnf
chmod -R a+rX . 2>/dev/null || true
if [ -n "${UG:-}" ]; then chown -R "$UG" . ; fi
EOF

if [ "${NO_DOCKER:-0}" = 1 ]; then
  W="$OUT" ALGS="${ALGS:-rsa ecdsa mldsa}" sh "$OUT/gen.sh"
else
  docker run --rm -v "$OUT:/w" -w /w -e UG="$(id -u):$(id -g)" \
    -e ALGS="${ALGS:-rsa ecdsa mldsa}" -e DAYS="${DAYS:-90}" -e SEND_ROOT="${SEND_ROOT:-0}" \
    -e SAN_SERVER="${SAN_SERVER:-spiffe://cluster.local/ns/default/sa/httpbin}" \
    -e SAN_CLIENT="${SAN_CLIENT:-spiffe://cluster.local/ns/default/sa/default}" \
    alpine:latest sh -c 'apk add -q --no-cache openssl && sh /w/gen.sh'
fi
rm -f "$OUT/gen.sh"
echo
echo "Gotowe: $OUT   (podsumowanie rozmiarów: $OUT/summary.txt)"
