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
