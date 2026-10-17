# Documentation backend yaml

``` yaml
      annotations:
        proxy.istio.io/config: |
          proxyStatsMatcher:
            inclusionRegexps:
            - ".*ssl.*"
            - ".*tls.*"
            - "cluster.inbound.*upstream_rq_total"

```

1. Same as in k6 - it chooses which metrics go to prometheus
2. `Service` port `8000` forwards to `targetPort: 8080` of the httpbin container. The k6 script calls `httpbin.default.svc.cluster.local:8000`
   - Sources:
     - https://kubernetes.io/docs/concepts/services-networking/service/
3. `nodeSelector: role: server` - the pod runs only on the node labelled as the server by `setup_cluster.sh`
4. `image: mccutchen/go-httpbin:2.18.3` - the backend application
   - Sources:
     - https://github.com/mccutchen/go-httpbin
