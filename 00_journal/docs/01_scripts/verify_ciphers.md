# Documentation of the verify_ciphers script

1. Main point of the script is to verify if all the envoyfiltr are okey and applying them change the cipher which k8s use
2. `check_delta()` - function that check if we have increase in value between two files
   - awk reads the "before" file first and then the "after" file (`NR == FNR`), and gets the pattern from the shell through `ENVIRON`
   - Sources:
     - https://pubs.opengroup.org/onlinepubs/9699919799/utilities/awk.html
3. `fetch_ssl_stats()` - function that fetch the ssl statistics in which we have a counter of the uses of the ciphers
   - reads `localhost:15000/stats` from the `istio-proxy` container and keeps only the `ssl.ciphers` / `ssl.curves` lines
   - Sources:
     - https://www.envoyproxy.io/docs/envoy/latest/operations/admin
     - https://www.envoyproxy.io/docs/envoy/latest/configuration/listeners/stats
4. `mktemp` - creates the empty temporary files for the stats before and after the traffic and for the k6 log
5. `fetch_ssl_stats "$HTTPBIN_POD"` before the traffic - reads the ssl counters from the httpbin side
6. k6 traffic: `echo "import http ..." | kubectl exec -i ... k6 run --vus 5 --duration 8s -` - the script is passed to k6 through stdin (`-`) and sends requests through the proxy for 8 seconds. `|| K6_EXIT=$?` saves the exit code without stopping the script (`set -e`)
   - Sources:
     - https://grafana.com/docs/k6/latest/get-started/running-k6/ 
7. `fetch_ssl_stats "$HTTPBIN_POD"` after the traffic - reads the counters again
8. `DIAG` - explains an empty result: `ADMIN_STATS_UNREACHABLE` if `/stats` returned nothing, `NO_SSL_COUNTERS` if there are no `ssl.ciphers` / `ssl.curves` lines. The second case can also come from a `proxyStatsMatcher` that does not include `ssl`
   - Sources:
     - https://istio.io/latest/docs/reference/config/annotations/
9. The `{ ... } | tee "$OUT_FILE"` block - writes the report to `04_results/Summary/verify_<name>.txt` and shows it on screen. `awk` prints only the counters that changed (after - before)
10. `check_delta` is called twice, for the cipher and for the curve. Result is `PASS` or `FAIL`. On `FAIL` the reason is stored in `FAILS`
