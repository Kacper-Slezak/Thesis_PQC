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
