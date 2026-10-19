# Statistical report (mode = handshake)

Rejected windows: 0 (k6 errors, dropped iterations, plaintext with handshakes or curve FAIL)


## Point: rate=200/s, mrpc=1

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum-full | 1 | 7775.5 | nan | [nan, nan] |
| mtls1.3-x25519 | 1 | 7314.6 | nan | [nan, nan] |
| mtls1.3-x25519-full | 1 | 6923.1 | nan | [nan, nan] |
| plaintext | 1 | 3427.7 | nan | [nan, nan] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum-full | 1 | 200.4 | nan | [nan, nan] |
| mtls1.3-x25519 | 1 | 199.6 | nan | [nan, nan] |
| mtls1.3-x25519-full | 1 | 200.5 | nan | [nan, nan] |
| plaintext | 1 | 198.3 | nan | [nan, nan] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum-full | 1 | 8.8 | nan | [nan, nan] |
| mtls1.3-x25519 | 1 | 8.0 | nan | [nan, nan] |
| mtls1.3-x25519-full | 1 | 7.4 | nan | [nan, nan] |
| plaintext | 1 | 3.7 | nan | [nan, nan] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum-full | 1 | 14.4 | nan | [nan, nan] |
| mtls1.3-x25519 | 1 | 14.7 | nan | [nan, nan] |
| mtls1.3-x25519-full | 1 | 12.2 | nan | [nan, nan] |
| plaintext | 1 | 5.5 | nan | [nan, nan] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|

## TLS session resumption

| setup | handshakes | reused | reused share | conn errors |
|---|---|---|---|---|
| mtls1.3-postquantum-full | 9301 | 0 | 0.0% | 0 |
| mtls1.3-x25519 | 9280 | 0 | 0.0% | 0 |
| mtls1.3-x25519-full | 9258 | 0 | 0.0% | 0 |

## Key exchange verification (curve_evidence.csv)

| setup | windows | PASS | FAIL |
|---|---|---|---|
| mtls1.3-postquantum-full | 1 | 1 | 0 |
| mtls1.3-x25519 | 1 | 1 | 0 |
| mtls1.3-x25519-full | 1 | 1 | 0 |
