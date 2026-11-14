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
