# Statistical report (mode = mrpc)

Rejected windows: 0 (k6 errors, dropped iterations, plaintext with handshakes or curve FAIL)


## Point: rate=100/s, mrpc=0

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.2-cbc | 3 | 1725.7 | 14.4 | [1689.9, 1761.5] |
| mtls1.2-chacha | 3 | 1591.3 | 21.8 | [1537.1, 1645.5] |
| mtls1.2-gcm | 3 | 1523.7 | 12.4 | [1492.8, 1554.6] |
| mtls1.2-gcm256 | 3 | 1523.3 | 13.1 | [1490.8, 1555.8] |
| mtls1.3-default | 3 | 1527.0 | 12.0 | [1497.2, 1556.8] |
| plaintext | 3 | 1352.9 | 12.4 | [1322.3, 1383.6] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.2-cbc | 3 | 100.1 | 0.1 | [99.8, 100.4] |
| mtls1.2-chacha | 3 | 99.9 | 0.1 | [99.8, 100.1] |
| mtls1.2-gcm | 3 | 100.1 | 0.2 | [99.7, 100.5] |
| mtls1.2-gcm256 | 3 | 100.2 | 0.1 | [99.9, 100.5] |
| mtls1.3-default | 3 | 100.1 | 0.0 | [100.1, 100.1] |
| plaintext | 3 | 100.0 | 0.1 | [99.9, 100.2] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.2-cbc | 3 | 2.0 | 0.0 | [2.0, 2.0] |
| mtls1.2-chacha | 3 | 2.0 | 0.0 | [1.9, 2.0] |
| mtls1.2-gcm | 3 | 1.9 | 0.0 | [1.9, 1.9] |
| mtls1.2-gcm256 | 3 | 1.9 | 0.0 | [1.9, 1.9] |
| mtls1.3-default | 3 | 1.9 | 0.0 | [1.9, 2.0] |
| plaintext | 3 | 1.8 | 0.0 | [1.8, 1.9] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.2-cbc | 3 | 7.9 | 0.2 | [7.3, 8.5] |
| mtls1.2-chacha | 3 | 7.8 | 0.0 | [7.7, 7.9] |
| mtls1.2-gcm | 3 | 7.7 | 0.1 | [7.6, 7.9] |
| mtls1.2-gcm256 | 3 | 7.8 | 0.1 | [7.5, 8.1] |
| mtls1.3-default | 3 | 7.7 | 0.1 | [7.5, 7.9] |
| plaintext | 3 | 7.4 | 0.1 | [7.3, 7.6] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-default | plaintext | 3 | +12.9% | [+8.1, +17.6] | [+nan, +nan] | 0.00724 | S12: +12.9% |
| window_rps | mtls1.3-default | plaintext | 3 | +0.1% | [-0.1, +0.2] | [+nan, +nan] | 0.184 | S12: +0.1% |
| p50_ms | mtls1.3-default | plaintext | 3 | +5.1% | [-0.2, +10.3] | [+nan, +nan] | 0.0538 | S12: +5.1% |
| p99_ms | mtls1.3-default | plaintext | 3 | +3.9% | [+2.1, +5.8] | [+nan, +nan] | 0.012 | S12: +3.9% |
| cpu_per_req_us | mtls1.2-gcm | mtls1.3-default | 3 | -0.2% | [-2.6, +2.2] | [+nan, +nan] | 0.741 | S12: -0.2% |
| window_rps | mtls1.2-gcm | mtls1.3-default | 3 | +0.0% | [-0.4, +0.4] | [+nan, +nan] | 1 | S12: +0.0% |
| p50_ms | mtls1.2-gcm | mtls1.3-default | 3 | -0.7% | [-3.5, +2.2] | [+nan, +nan] | 0.408 | S12: -0.7% |
| p99_ms | mtls1.2-gcm | mtls1.3-default | 3 | +0.2% | [-3.5, +3.8] | [+nan, +nan] | 0.867 | S12: +0.2% |
| cpu_per_req_us | mtls1.2-gcm256 | mtls1.3-default | 3 | -0.2% | [-3.0, +2.5] | [+nan, +nan] | 0.745 | S12: -0.2% |
| window_rps | mtls1.2-gcm256 | mtls1.3-default | 3 | +0.1% | [-0.2, +0.4] | [+nan, +nan] | 0.423 | S12: +0.1% |
| p50_ms | mtls1.2-gcm256 | mtls1.3-default | 3 | -0.8% | [-2.4, +0.8] | [+nan, +nan] | 0.156 | S12: -0.8% |
| p99_ms | mtls1.2-gcm256 | mtls1.3-default | 3 | +1.0% | [-6.1, +8.1] | [+nan, +nan] | 0.619 | S12: +1.0% |
| cpu_per_req_us | mtls1.2-chacha | mtls1.3-default | 3 | +4.2% | [+1.7, +6.7] | [+nan, +nan] | 0.018 | S12: +4.2% |
| window_rps | mtls1.2-chacha | mtls1.3-default | 3 | -0.2% | [-0.3, -0.0] | [+nan, +nan] | 0.0377 | S12: -0.2% |
| p50_ms | mtls1.2-chacha | mtls1.3-default | 3 | +1.4% | [-0.0, +2.8] | [+nan, +nan] | 0.0511 | S12: +1.4% |
| p99_ms | mtls1.2-chacha | mtls1.3-default | 3 | +1.2% | [-2.8, +5.2] | [+nan, +nan] | 0.335 | S12: +1.2% |
| cpu_per_req_us | mtls1.2-cbc | mtls1.3-default | 3 | +13.0% | [+12.9, +13.2] | [+nan, +nan] | 8.06e-06 | S12: +13.0% |
| window_rps | mtls1.2-cbc | mtls1.3-default | 3 | -0.0% | [-0.3, +0.3] | [+nan, +nan] | 0.667 | S12: -0.0% |
| p50_ms | mtls1.2-cbc | mtls1.3-default | 3 | +3.3% | [+2.2, +4.4] | [+nan, +nan] | 0.00603 | S12: +3.3% |
| p99_ms | mtls1.2-cbc | mtls1.3-default | 3 | +2.8% | [-7.4, +13.0] | [+nan, +nan] | 0.364 | S12: +2.8% |

## TLS session resumption

| setup | handshakes | reused | reused share | conn errors |
|---|---|---|---|---|
| mtls1.2-cbc | 0 | 0 | 0.0% | 0 |
| mtls1.2-chacha | 0 | 0 | 0.0% | 0 |
| mtls1.2-gcm | 0 | 0 | 0.0% | 0 |
| mtls1.2-gcm256 | 0 | 0 | 0.0% | 0 |
| mtls1.3-default | 0 | 0 | 0.0% | 0 |

## Key exchange verification (curve_evidence.csv)

| setup | windows | PASS | FAIL |
|---|---|---|---|
| mtls1.2-cbc | 3 | 0 | 0 |
| mtls1.2-chacha | 3 | 0 | 0 |
| mtls1.2-gcm | 3 | 0 | 0 |
| mtls1.2-gcm256 | 3 | 0 | 0 |
| mtls1.3-default | 3 | 0 | 0 |
