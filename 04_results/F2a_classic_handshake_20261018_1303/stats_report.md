# Statistical report (mode = mrpc)

Rejected windows: 0 (k6 errors, dropped iterations, plaintext with handshakes or curve FAIL)


## Point: rate=200/s, mrpc=1

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.2-cbc | 3 | 2416.4 | 14.3 | [2381.0, 2451.8] |
| mtls1.2-chacha | 3 | 2379.4 | 8.2 | [2359.0, 2399.8] |
| mtls1.2-gcm | 3 | 2376.5 | 26.9 | [2309.7, 2443.2] |
| mtls1.2-gcm256 | 3 | 2378.6 | 9.8 | [2354.2, 2403.0] |
| mtls1.3-default | 3 | 2580.3 | 34.2 | [2495.3, 2665.3] |
| plaintext | 3 | 1703.7 | 2.0 | [1698.8, 1708.5] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.2-cbc | 3 | 200.4 | 0.3 | [199.7, 201.1] |
| mtls1.2-chacha | 3 | 200.5 | 0.3 | [199.7, 201.2] |
| mtls1.2-gcm | 3 | 200.4 | 0.2 | [199.9, 200.9] |
| mtls1.2-gcm256 | 3 | 200.4 | 0.1 | [200.1, 200.7] |
| mtls1.3-default | 3 | 200.3 | 0.1 | [200.0, 200.6] |
| plaintext | 3 | 200.6 | 0.5 | [199.3, 201.8] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.2-cbc | 3 | 2.1 | 0.0 | [2.0, 2.1] |
| mtls1.2-chacha | 3 | 2.0 | 0.0 | [2.0, 2.1] |
| mtls1.2-gcm | 3 | 2.0 | 0.0 | [2.0, 2.0] |
| mtls1.2-gcm256 | 3 | 2.0 | 0.0 | [2.0, 2.1] |
| mtls1.3-default | 3 | 2.2 | 0.0 | [2.1, 2.2] |
| plaintext | 3 | 1.6 | 0.0 | [1.5, 1.6] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.2-cbc | 3 | 10.2 | 0.1 | [10.0, 10.4] |
| mtls1.2-chacha | 3 | 10.2 | 0.4 | [9.3, 11.1] |
| mtls1.2-gcm | 3 | 10.3 | 0.2 | [9.8, 10.8] |
| mtls1.2-gcm256 | 3 | 10.2 | 0.1 | [10.1, 10.3] |
| mtls1.3-default | 3 | 12.5 | 0.2 | [11.9, 13.0] |
| plaintext | 3 | 7.7 | 0.2 | [7.3, 8.1] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-default | plaintext | 3 | +51.5% | [+46.8, +56.1] | [+nan, +nan] | 0.000447 | S11: +51.5% |
| window_rps | mtls1.3-default | plaintext | 3 | -0.1% | [-0.6, +0.4] | [+nan, +nan] | 0.398 | S11: -0.1% |
| p50_ms | mtls1.3-default | plaintext | 3 | +38.9% | [+34.9, +43.0] | [+nan, +nan] | 0.000592 | S11: +38.9% |
| p99_ms | mtls1.3-default | plaintext | 3 | +61.7% | [+50.7, +72.8] | [+nan, +nan] | 0.00173 | S11: +61.7% |
| cpu_per_req_us | mtls1.2-gcm | mtls1.3-default | 3 | -7.9% | [-9.3, -6.5] | [+nan, +nan] | 0.0017 | S11: -7.9% |
| window_rps | mtls1.2-gcm | mtls1.3-default | 3 | +0.0% | [-0.3, +0.4] | [+nan, +nan] | 0.741 | S11: +0.0% |
| p50_ms | mtls1.2-gcm | mtls1.3-default | 3 | -6.0% | [-9.4, -2.5] | [+nan, +nan] | 0.0176 | S11: -6.0% |
| p99_ms | mtls1.2-gcm | mtls1.3-default | 3 | -17.3% | [-18.5, -16.1] | [+nan, +nan] | 0.000256 | S11: -17.3% |
| cpu_per_req_us | mtls1.2-gcm256 | mtls1.3-default | 3 | -7.8% | [-10.4, -5.2] | [+nan, +nan] | 0.00588 | S11: -7.8% |
| window_rps | mtls1.2-gcm256 | mtls1.3-default | 3 | +0.0% | [-0.2, +0.3] | [+nan, +nan] | 0.478 | S11: +0.0% |
| p50_ms | mtls1.2-gcm256 | mtls1.3-default | 3 | -5.3% | [-8.1, -2.6] | [+nan, +nan] | 0.0145 | S11: -5.3% |
| p99_ms | mtls1.2-gcm256 | mtls1.3-default | 3 | -18.4% | [-23.0, -13.7] | [+nan, +nan] | 0.00344 | S11: -18.4% |
| cpu_per_req_us | mtls1.2-chacha | mtls1.3-default | 3 | -7.8% | [-10.4, -5.1] | [+nan, +nan] | 0.00614 | S11: -7.8% |
| window_rps | mtls1.2-chacha | mtls1.3-default | 3 | +0.1% | [-0.2, +0.4] | [+nan, +nan] | 0.423 | S11: +0.1% |
| p50_ms | mtls1.2-chacha | mtls1.3-default | 3 | -5.7% | [-9.2, -2.2] | [+nan, +nan] | 0.02 | S11: -5.7% |
| p99_ms | mtls1.2-chacha | mtls1.3-default | 3 | -18.0% | [-28.7, -7.3] | [+nan, +nan] | 0.0185 | S11: -18.0% |
| cpu_per_req_us | mtls1.2-cbc | mtls1.3-default | 3 | -6.3% | [-10.7, -2.0] | [+nan, +nan] | 0.0242 | S11: -6.3% |
| window_rps | mtls1.2-cbc | mtls1.3-default | 3 | +0.0% | [-0.2, +0.2] | [+nan, +nan] | 0.529 | S11: +0.0% |
| p50_ms | mtls1.2-cbc | mtls1.3-default | 3 | -4.6% | [-8.3, -0.9] | [+nan, +nan] | 0.0325 | S11: -4.6% |
| p99_ms | mtls1.2-cbc | mtls1.3-default | 3 | -18.1% | [-23.2, -12.9] | [+nan, +nan] | 0.00435 | S11: -18.1% |

## TLS session resumption

| setup | handshakes | reused | reused share | conn errors |
|---|---|---|---|---|
| mtls1.2-cbc | 27356 | 54704 | 100.0% | 0 |
| mtls1.2-chacha | 27359 | 54709 | 100.0% | 0 |
| mtls1.2-gcm | 27370 | 54729 | 100.0% | 0 |
| mtls1.2-gcm256 | 27362 | 54700 | 100.0% | 0 |
| mtls1.3-default | 27348 | 53742 | 98.3% | 0 |

## Key exchange verification (curve_evidence.csv)

| setup | windows | PASS | FAIL |
|---|---|---|---|
| mtls1.2-cbc | 3 | 0 | 0 |
| mtls1.2-chacha | 3 | 0 | 0 |
| mtls1.2-gcm | 3 | 0 | 0 |
| mtls1.2-gcm256 | 3 | 0 | 0 |
| mtls1.3-default | 3 | 0 | 0 |
