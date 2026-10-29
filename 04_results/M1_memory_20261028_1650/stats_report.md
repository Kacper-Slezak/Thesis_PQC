# Statistical report (mode = grid)

Rejected windows: 8 (k6 errors, dropped iterations, plaintext with handshakes or curve FAIL)

- mtls1.3-x25519-full session=3 run=1: fail_rate=0 dropped=1492 handshakes=16577
- mtls1.3-x25519 session=3 run=1: fail_rate=0 dropped=683 handshakes=17292
- mtls1.3-postquantum-full session=3 run=1: fail_rate=0 dropped=1652 handshakes=16403
- mtls1.3-postquantum session=3 run=1: fail_rate=0 dropped=625 handshakes=17409
- mtls1.3-x25519-full session=3 run=2: fail_rate=0 dropped=1618 handshakes=16448
- mtls1.3-x25519 session=3 run=2: fail_rate=0 dropped=663 handshakes=17369
- mtls1.3-postquantum-full session=3 run=2: fail_rate=0 dropped=1832 handshakes=16278
- mtls1.3-postquantum session=3 run=2: fail_rate=0 dropped=1027 handshakes=17015

## Point: rate=100/s, mrpc=0

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 2255.0 | 4.0 | [2219.4, 2290.6] |
| mtls1.3-postquantum-full | 2 | 2258.2 | 14.4 | [2129.2, 2387.1] |
| mtls1.3-x25519 | 2 | 2252.9 | 10.3 | [2160.1, 2345.7] |
| mtls1.3-x25519-full | 2 | 2290.2 | 25.2 | [2063.3, 2517.0] |
| plaintext | 2 | 2097.2 | 1.8 | [2081.3, 2113.0] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 100.2 | 0.1 | [99.6, 100.9] |
| mtls1.3-postquantum-full | 2 | 100.3 | 0.0 | [100.3, 100.3] |
| mtls1.3-x25519 | 2 | 100.2 | 0.1 | [99.6, 100.9] |
| mtls1.3-x25519-full | 2 | 100.3 | 0.0 | [100.3, 100.3] |
| plaintext | 2 | 100.3 | 0.1 | [99.7, 101.0] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 2.6 | 0.0 | [2.2, 2.9] |
| mtls1.3-postquantum-full | 2 | 2.6 | 0.0 | [2.6, 2.6] |
| mtls1.3-x25519 | 2 | 2.6 | 0.0 | [2.6, 2.6] |
| mtls1.3-x25519-full | 2 | 2.6 | 0.0 | [2.4, 2.8] |
| plaintext | 2 | 2.5 | 0.0 | [2.5, 2.5] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 7.3 | 0.0 | [7.1, 7.6] |
| mtls1.3-postquantum-full | 2 | 7.5 | 0.1 | [6.3, 8.7] |
| mtls1.3-x25519 | 2 | 7.4 | 0.0 | [7.3, 7.4] |
| mtls1.3-x25519-full | 2 | 7.4 | 0.3 | [4.9, 10.0] |
| plaintext | 2 | 6.9 | 0.1 | [6.3, 7.4] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +7.4% | [+2.2, +12.7] | [+nan, +nan] | 0.0353 | S3: +7.4% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | -0.1% | [-1.4, +1.2] | [+nan, +nan] | 0.5 | S3: -0.1% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +3.3% | [+2.1, +4.4] | [+nan, +nan] | 0.0177 | S3: +3.3% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | +6.9% | [-2.1, +15.9] | [+nan, +nan] | 0.0651 | S3: +6.9% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +9.2% | [-2.4, +20.8] | [+nan, +nan] | 0.0632 | S3: +9.2% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | -0.0% | [-0.7, +0.6] | [+nan, +nan] | 0.5 | S3: -0.0% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +4.1% | [-3.5, +11.6] | [+nan, +nan] | 0.093 | S3: +4.1% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +7.9% | [-37.9, +53.8] | [+nan, +nan] | 0.272 | S3: +7.9% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +1.7% | [-4.2, +7.5] | [+nan, +nan] | 0.174 | S3: +1.7% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +0.0% | [-0.6, +0.7] | [+nan, +nan] | 0.5 | S3: +0.0% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +0.8% | [-5.4, +7.0] | [+nan, +nan] | 0.36 | S3: +0.8% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +1.0% | [-33.5, +35.4] | [+nan, +nan] | 0.784 | S3: +1.0% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -1.4% | [-5.5, +2.7] | [+nan, +nan] | 0.146 | S3: -1.4% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +0.0% | [+0.0, +0.0] | [+nan, +nan] | nan | S3: +0.0% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -1.2% | [-8.4, +5.9] | [+nan, +nan] | 0.271 | S3: -1.2% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +0.6% | [-17.9, +19.0] | [+nan, +nan] | 0.768 | S3: +0.6% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +0.1% | [-5.6, +5.8] | [+nan, +nan] | 0.868 | S3: +0.1% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +0.0% | [-1.3, +1.3] | [+nan, +nan] | 1 | S3: +0.0% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | -0.5% | [-14.6, +13.6] | [+nan, +nan] | 0.724 | S3: -0.5% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | -0.4% | [-4.7, +3.9] | [+nan, +nan] | 0.441 | S3: -0.4% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.1% | [-7.2, +7.4] | [+nan, +nan] | 0.847 | S3: +0.1% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.0% | [-0.6, +0.7] | [+nan, +nan] | 0.5 | S3: +0.0% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.0% | [-13.1, +13.2] | [+nan, +nan] | 0.97 | S3: +0.0% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +1.9% | [-18.6, +22.4] | [+nan, +nan] | 0.448 | S3: +1.9% |

## Point: rate=100/s, mrpc=1

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 5775.4 | 31.1 | [5495.9, 6054.9] |
| mtls1.3-postquantum-full | 2 | 7876.1 | 25.1 | [7650.5, 8101.6] |
| mtls1.3-x25519 | 2 | 5619.8 | 112.0 | [4613.5, 6626.1] |
| mtls1.3-x25519-full | 2 | 7613.0 | 4.8 | [7569.8, 7656.2] |
| plaintext | 2 | 3582.9 | 15.3 | [3445.7, 3720.1] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 100.3 | 0.1 | [99.7, 101.0] |
| mtls1.3-postquantum-full | 2 | 100.4 | 0.1 | [99.1, 101.7] |
| mtls1.3-x25519 | 2 | 100.7 | 0.6 | [95.6, 105.8] |
| mtls1.3-x25519-full | 2 | 100.3 | 0.0 | [100.3, 100.3] |
| plaintext | 2 | 100.2 | 0.2 | [98.2, 102.1] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 5.1 | 0.0 | [5.0, 5.3] |
| mtls1.3-postquantum-full | 2 | 7.1 | 0.0 | [7.0, 7.1] |
| mtls1.3-x25519 | 2 | 4.9 | 0.1 | [4.3, 5.5] |
| mtls1.3-x25519-full | 2 | 6.8 | 0.0 | [6.6, 7.0] |
| plaintext | 2 | 3.4 | 0.0 | [3.1, 3.7] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 15.1 | 0.1 | [14.5, 15.6] |
| mtls1.3-postquantum-full | 2 | 18.5 | 0.1 | [17.3, 19.8] |
| mtls1.3-x25519 | 2 | 15.2 | 0.3 | [12.4, 18.0] |
| mtls1.3-x25519-full | 2 | 18.7 | 0.6 | [13.1, 24.4] |
| plaintext | 2 | 9.1 | 0.2 | [7.4, 10.7] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +56.8% | [+34.8, +78.9] | [+nan, +nan] | 0.0195 | S3: +56.8% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | +0.5% | [-2.6, +3.7] | [+nan, +nan] | 0.271 | S3: +0.5% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +44.6% | [+40.4, +48.8] | [+nan, +nan] | 0.00471 | S3: +44.6% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | +67.1% | [+6.2, +128.0] | [+nan, +nan] | 0.0454 | S3: +67.1% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +112.5% | [+105.6, +119.4] | [+nan, +nan] | 0.00309 | S3: +112.5% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | +0.1% | [-1.8, +2.1] | [+nan, +nan] | 0.5 | S3: +0.1% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +99.7% | [+86.1, +113.4] | [+nan, +nan] | 0.00684 | S3: +99.7% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +106.3% | [+81.0, +131.6] | [+nan, +nan] | 0.0119 | S3: +106.3% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +35.5% | [+12.0, +59.0] | [+nan, +nan] | 0.0331 | S3: +35.5% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | -0.4% | [-5.4, +4.6] | [+nan, +nan] | 0.5 | S3: -0.4% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +38.2% | [+24.7, +51.6] | [+nan, +nan] | 0.0176 | S3: +38.2% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +23.6% | [-36.6, +83.9] | [+nan, +nan] | 0.126 | S3: +23.6% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +3.5% | [-0.1, +7.0] | [+nan, +nan] | 0.0514 | S3: +3.5% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +0.1% | [-1.2, +1.4] | [+nan, +nan] | 0.5 | S3: +0.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +3.8% | [+1.5, +6.1] | [+nan, +nan] | 0.0309 | S3: +3.8% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -1.1% | [-37.9, +35.8] | [+nan, +nan] | 0.778 | S3: -1.1% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +2.8% | [-20.6, +26.2] | [+nan, +nan] | 0.371 | S3: +2.8% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | -0.3% | [-4.7, +4.1] | [+nan, +nan] | 0.5 | S3: -0.3% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +4.1% | [-11.6, +19.8] | [+nan, +nan] | 0.187 | S3: +4.1% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | -0.6% | [-15.2, +14.1] | [+nan, +nan] | 0.716 | S3: -0.6% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +36.4% | [+33.7, +39.1] | [+nan, +nan] | 0.00371 | S3: +36.4% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.0% | [-0.6, +0.7] | [+nan, +nan] | 0.5 | S3: +0.0% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +37.8% | [+33.5, +42.1] | [+nan, +nan] | 0.0057 | S3: +37.8% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +22.9% | [+18.9, +26.9] | [+nan, +nan] | 0.00871 | S3: +22.9% |

## Point: rate=100/s, mrpc=2

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 4157.1 | 20.2 | [3976.1, 4338.2] |
| mtls1.3-postquantum-full | 2 | 5177.5 | 35.8 | [4856.0, 5499.0] |
| mtls1.3-x25519 | 2 | 3980.1 | 24.5 | [3759.6, 4200.5] |
| mtls1.3-x25519-full | 2 | 5037.2 | 33.1 | [4739.9, 5334.5] |
| plaintext | 2 | 2885.6 | 11.8 | [2779.5, 2991.6] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 100.8 | 0.6 | [95.0, 106.5] |
| mtls1.3-postquantum-full | 2 | 101.6 | 1.8 | [85.1, 118.1] |
| mtls1.3-x25519 | 2 | 101.4 | 1.8 | [84.9, 117.9] |
| mtls1.3-x25519-full | 2 | 100.3 | 0.0 | [100.3, 100.3] |
| plaintext | 2 | 101.5 | 1.8 | [85.6, 117.3] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 4.5 | 0.1 | [3.9, 5.0] |
| mtls1.3-postquantum-full | 2 | 6.3 | 0.1 | [5.7, 6.9] |
| mtls1.3-x25519 | 2 | 4.2 | 0.1 | [3.7, 4.7] |
| mtls1.3-x25519-full | 2 | 6.0 | 0.0 | [5.8, 6.1] |
| plaintext | 2 | 3.0 | 0.0 | [2.6, 3.5] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 12.4 | 1.4 | [0.2, 24.6] |
| mtls1.3-postquantum-full | 2 | 15.0 | 0.1 | [14.5, 15.5] |
| mtls1.3-x25519 | 2 | 11.6 | 0.1 | [10.4, 12.8] |
| mtls1.3-x25519-full | 2 | 14.3 | 0.5 | [9.8, 18.9] |
| plaintext | 2 | 8.5 | 0.0 | [8.4, 8.5] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +37.9% | [+25.2, +50.6] | [+nan, +nan] | 0.0168 | S3: +37.9% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | -0.0% | [-0.7, +0.6] | [+nan, +nan] | 0.5 | S3: -0.0% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +38.5% | [+36.3, +40.7] | [+nan, +nan] | 0.00286 | S3: +38.5% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | +37.1% | [+22.6, +51.5] | [+nan, +nan] | 0.0196 | S3: +37.1% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +74.6% | [+57.8, +91.3] | [+nan, +nan] | 0.0112 | S3: +74.6% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | -1.1% | [-16.6, +14.4] | [+nan, +nan] | 0.527 | S3: -1.1% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +95.9% | [+73.5, +118.3] | [+nan, +nan] | 0.0117 | S3: +95.9% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +69.2% | [+15.1, +123.2] | [+nan, +nan] | 0.0391 | S3: +69.2% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +26.6% | [+26.1, +27.0] | [+nan, +nan] | 0.000868 | S3: +26.6% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | -1.1% | [-17.2, +15.0] | [+nan, +nan] | 0.554 | S3: -1.1% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +41.5% | [+27.5, +55.4] | [+nan, +nan] | 0.0168 | S3: +41.5% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +23.5% | [-29.0, +75.9] | [+nan, +nan] | 0.111 | S3: +23.5% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +2.8% | [-9.7, +15.2] | [+nan, +nan] | 0.215 | S3: +2.8% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +1.3% | [-15.2, +17.8] | [+nan, +nan] | 0.5 | S3: +1.3% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +5.5% | [-1.8, +12.8] | [+nan, +nan] | 0.066 | S3: +5.5% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +4.7% | [-32.0, +41.5] | [+nan, +nan] | 0.349 | S3: +4.7% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +4.5% | [+3.2, +5.7] | [+nan, +nan] | 0.0139 | S3: +4.5% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | -0.6% | [-11.2, +9.9] | [+nan, +nan] | 0.587 | S3: -0.6% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +6.1% | [+5.6, +6.6] | [+nan, +nan] | 0.00426 | S3: +6.1% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +7.2% | [-109.4, +123.7] | [+nan, +nan] | 0.578 | S3: +7.2% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +24.5% | [+11.4, +37.7] | [+nan, +nan] | 0.0268 | S3: +24.5% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.8% | [-9.8, +11.5] | [+nan, +nan] | 0.5 | S3: +0.8% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +40.7% | [+36.0, +45.5] | [+nan, +nan] | 0.00589 | S3: +40.7% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +21.4% | [-101.8, +144.5] | [+nan, +nan] | 0.271 | S3: +21.4% |

## Point: rate=100/s, mrpc=5

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 3038.2 | 28.2 | [2784.8, 3291.7] |
| mtls1.3-postquantum-full | 2 | 3499.2 | 11.0 | [3400.7, 3597.6] |
| mtls1.3-x25519 | 2 | 2969.3 | 33.8 | [2665.6, 3273.0] |
| mtls1.3-x25519-full | 2 | 3397.6 | 10.7 | [3301.6, 3493.5] |
| plaintext | 2 | 2390.7 | 30.2 | [2119.4, 2661.9] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 101.6 | 2.0 | [83.8, 119.4] |
| mtls1.3-postquantum-full | 2 | 101.7 | 1.8 | [85.2, 118.2] |
| mtls1.3-x25519 | 2 | 100.8 | 1.1 | [91.2, 110.3] |
| mtls1.3-x25519-full | 2 | 101.6 | 1.8 | [85.1, 118.1] |
| plaintext | 2 | 101.6 | 1.9 | [84.4, 118.7] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 3.0 | 0.1 | [2.3, 3.6] |
| mtls1.3-postquantum-full | 2 | 3.0 | 0.0 | [2.6, 3.3] |
| mtls1.3-x25519 | 2 | 3.0 | 0.1 | [2.3, 3.6] |
| mtls1.3-x25519-full | 2 | 3.0 | 0.0 | [2.8, 3.2] |
| plaintext | 2 | 2.8 | 0.1 | [2.2, 3.3] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 10.2 | 0.2 | [8.5, 11.9] |
| mtls1.3-postquantum-full | 2 | 13.6 | 0.3 | [10.6, 16.6] |
| mtls1.3-x25519 | 2 | 9.5 | 0.5 | [4.8, 14.2] |
| mtls1.3-x25519-full | 2 | 12.6 | 0.2 | [11.0, 14.2] |
| plaintext | 2 | 7.5 | 0.3 | [4.7, 10.4] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +24.2% | [+22.8, +25.6] | [+nan, +nan] | 0.00288 | S3: +24.2% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | -0.8% | [-8.2, +6.6] | [+nan, +nan] | 0.407 | S3: -0.8% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +7.6% | [+3.9, +11.3] | [+nan, +nan] | 0.0243 | S3: +7.6% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | +26.2% | [+12.1, +40.3] | [+nan, +nan] | 0.0269 | S3: +26.2% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +42.1% | [+22.0, +62.3] | [+nan, +nan] | 0.0239 | S3: +42.1% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | +0.0% | [-0.6, +0.7] | [+nan, +nan] | 0.5 | S3: +0.0% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +7.4% | [-5.5, +20.2] | [+nan, +nan] | 0.0869 | S3: +7.4% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +67.9% | [+24.9, +110.9] | [+nan, +nan] | 0.0317 | S3: +67.9% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +14.4% | [-0.5, +29.4] | [+nan, +nan] | 0.0517 | S3: +14.4% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +0.8% | [-6.0, +7.7] | [+nan, +nan] | 0.364 | S3: +0.8% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | -0.2% | [-15.6, +15.2] | [+nan, +nan] | 0.886 | S3: -0.2% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +33.1% | [-15.9, +82.0] | [+nan, +nan] | 0.0738 | S3: +33.1% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +3.0% | [-2.8, +8.8] | [+nan, +nan] | 0.0965 | S3: +3.0% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +0.1% | [+0.1, +0.1] | [+nan, +nan] | 0.00815 | S3: +0.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -0.2% | [-5.3, +4.8] | [+nan, +nan] | 0.667 | S3: -0.2% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +7.5% | [-2.8, +17.8] | [+nan, +nan] | 0.0687 | S3: +7.5% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +2.3% | [+0.4, +4.3] | [+nan, +nan] | 0.0415 | S3: +2.3% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +0.8% | [-7.3, +9.0] | [+nan, +nan] | 0.414 | S3: +0.8% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | -0.7% | [-1.0, -0.4] | [+nan, +nan] | 0.0199 | S3: -0.7% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +7.4% | [-27.6, +42.4] | [+nan, +nan] | 0.227 | S3: +7.4% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +15.2% | [+8.8, +21.5] | [+nan, +nan] | 0.021 | S3: +15.2% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.1% | [-1.2, +1.4] | [+nan, +nan] | 0.5 | S3: +0.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.3% | [-9.8, +10.3] | [+nan, +nan] | 0.799 | S3: +0.3% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +33.2% | [+25.9, +40.4] | [+nan, +nan] | 0.011 | S3: +33.2% |

## Point: rate=200/s, mrpc=0

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 1912.4 | 196.2 | [150.0, 3674.8] |
| mtls1.3-postquantum-full | 2 | 1900.1 | 214.6 | [-28.1, 3828.2] |
| mtls1.3-x25519 | 2 | 1887.8 | 196.7 | [120.4, 3655.2] |
| mtls1.3-x25519-full | 2 | 1903.5 | 199.5 | [110.7, 3696.3] |
| plaintext | 2 | 1793.8 | 204.4 | [-42.9, 3630.4] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 203.4 | 4.9 | [158.9, 247.9] |
| mtls1.3-postquantum-full | 2 | 203.4 | 5.0 | [158.3, 248.6] |
| mtls1.3-x25519 | 2 | 203.3 | 4.8 | [160.1, 246.5] |
| mtls1.3-x25519-full | 2 | 203.4 | 5.0 | [158.3, 248.6] |
| plaintext | 2 | 203.5 | 4.8 | [160.3, 246.7] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 2.4 | 0.1 | [1.8, 3.1] |
| mtls1.3-postquantum-full | 2 | 2.4 | 0.1 | [1.7, 3.2] |
| mtls1.3-x25519 | 2 | 2.4 | 0.1 | [1.6, 3.2] |
| mtls1.3-x25519-full | 2 | 2.4 | 0.1 | [1.7, 3.1] |
| plaintext | 2 | 2.4 | 0.1 | [1.4, 3.3] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 5.7 | 2.5 | [-16.4, 27.7] |
| mtls1.3-postquantum-full | 2 | 5.5 | 3.0 | [-21.1, 32.0] |
| mtls1.3-x25519 | 2 | 5.5 | 2.8 | [-19.5, 30.4] |
| mtls1.3-x25519-full | 2 | 5.9 | 2.4 | [-15.4, 27.2] |
| plaintext | 2 | 5.5 | 3.1 | [-22.3, 33.3] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +5.3% | [-4.0, +14.6] | [+nan, +nan] | 0.0872 | S3: +5.3% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | -0.1% | [-0.1, -0.1] | [+nan, +nan] | 0.0106 | S3: -0.1% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +1.7% | [-4.3, +7.8] | [+nan, +nan] | 0.171 | S3: +1.7% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | +1.3% | [-57.2, +59.8] | [+nan, +nan] | 0.826 | S3: +1.3% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +6.2% | [-2.6, +14.9] | [+nan, +nan] | 0.0708 | S3: +6.2% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | -0.0% | [-1.0, +0.9] | [+nan, +nan] | 0.787 | S3: -0.0% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +2.0% | [-9.0, +13.0] | [+nan, +nan] | 0.258 | S3: +2.0% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +13.0% | [-171.3, +197.2] | [+nan, +nan] | 0.535 | S3: +13.0% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +0.8% | [+0.3, +1.4] | [+nan, +nan] | 0.0345 | S3: +0.8% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +0.1% | [-0.8, +1.0] | [+nan, +nan] | 0.5 | S3: +0.1% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +0.3% | [-4.6, +5.1] | [+nan, +nan] | 0.593 | S3: +0.3% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +11.1% | [-106.6, +128.8] | [+nan, +nan] | 0.442 | S3: +11.1% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -0.2% | [-7.5, +7.1] | [+nan, +nan] | 0.764 | S3: -0.2% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +0.0% | [+0.0, +0.0] | [+nan, +nan] | nan | S3: +0.0% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -0.1% | [-2.1, +2.0] | [+nan, +nan] | 0.756 | S3: -0.1% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -9.6% | [-133.8, +114.6] | [+nan, +nan] | 0.505 | S3: -9.6% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +1.3% | [-0.2, +2.8] | [+nan, +nan] | 0.057 | S3: +1.3% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +0.0% | [-0.6, +0.7] | [+nan, +nan] | 0.5 | S3: +0.0% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +0.3% | [-7.3, +7.9] | [+nan, +nan] | 0.695 | S3: +0.3% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +6.0% | [-74.2, +86.2] | [+nan, +nan] | 0.516 | S3: +6.0% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | -0.7% | [-10.0, +8.6] | [+nan, +nan] | 0.515 | S3: -0.7% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.0% | [-0.3, +0.3] | [+nan, +nan] | 0.5 | S3: +0.0% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | -0.1% | [-5.0, +4.8] | [+nan, +nan] | 0.849 | S3: -0.1% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | -5.6% | [-106.9, +95.6] | [+nan, +nan] | 0.607 | S3: -5.6% |

## Point: rate=200/s, mrpc=1

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 5269.2 | 553.7 | [294.7, 10243.7] |
| mtls1.3-postquantum-full | 2 | 7206.0 | 623.2 | [1607.1, 12805.0] |
| mtls1.3-x25519 | 2 | 4914.8 | 505.0 | [377.4, 9452.2] |
| mtls1.3-x25519-full | 2 | 6892.9 | 522.1 | [2201.8, 11584.0] |
| plaintext | 2 | 3132.0 | 298.7 | [448.4, 5815.6] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 203.9 | 5.6 | [153.7, 254.0] |
| mtls1.3-postquantum-full | 2 | 203.6 | 2.8 | [178.9, 228.4] |
| mtls1.3-x25519 | 2 | 201.7 | 2.5 | [179.4, 223.9] |
| mtls1.3-x25519-full | 2 | 201.8 | 2.6 | [178.2, 225.3] |
| plaintext | 2 | 203.8 | 5.3 | [156.1, 251.4] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 5.0 | 0.3 | [2.5, 7.5] |
| mtls1.3-postquantum-full | 2 | 7.5 | 0.3 | [4.8, 10.1] |
| mtls1.3-x25519 | 2 | 4.7 | 0.2 | [3.0, 6.3] |
| mtls1.3-x25519-full | 2 | 7.1 | 0.3 | [4.6, 9.7] |
| plaintext | 2 | 3.2 | 0.1 | [2.2, 4.2] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 17.3 | 13.1 | [-100.3, 135.0] |
| mtls1.3-postquantum-full | 2 | 27.8 | 17.2 | [-126.8, 182.4] |
| mtls1.3-x25519 | 2 | 16.4 | 12.2 | [-93.3, 126.2] |
| mtls1.3-x25519-full | 2 | 21.7 | 16.0 | [-121.9, 165.4] |
| plaintext | 2 | 7.5 | 3.4 | [-22.7, 37.8] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +56.9% | [+46.4, +67.3] | [+nan, +nan] | 0.00922 | S3: +56.9% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | -1.0% | [-13.2, +11.2] | [+nan, +nan] | 0.484 | S3: -1.0% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +43.7% | [+38.7, +48.8] | [+nan, +nan] | 0.00579 | S3: +43.7% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | +101.8% | [-544.8, +748.4] | [+nan, +nan] | 0.295 | S3: +101.8% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +120.3% | [+81.3, +159.3] | [+nan, +nan] | 0.0162 | S3: +120.3% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | -1.0% | [-12.6, +10.7] | [+nan, +nan] | 0.483 | S3: -1.0% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +120.7% | [+109.7, +131.6] | [+nan, +nan] | 0.00454 | S3: +120.7% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +167.5% | [-665.3, +1000.3] | [+nan, +nan] | 0.237 | S3: +167.5% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +40.4% | [+6.2, +74.7] | [+nan, +nan] | 0.0423 | S3: +40.4% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +0.0% | [-0.6, +0.7] | [+nan, +nan] | 0.5 | S3: +0.0% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +53.5% | [+51.3, +55.7] | [+nan, +nan] | 0.00206 | S3: +53.5% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +32.8% | [+20.0, +45.6] | [+nan, +nan] | 0.0196 | S3: +32.8% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +4.5% | [-5.6, +14.6] | [+nan, +nan] | 0.111 | S3: +4.5% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +0.9% | [+0.4, +1.5] | [+nan, +nan] | 0.0277 | S3: +0.9% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +4.5% | [+4.0, +5.0] | [+nan, +nan] | 0.00545 | S3: +4.5% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +35.4% | [-148.3, +219.2] | [+nan, +nan] | 0.247 | S3: +35.4% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +7.2% | [+4.9, +9.4] | [+nan, +nan] | 0.0156 | S3: +7.2% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +1.1% | [-12.7, +14.8] | [+nan, +nan] | 0.5 | S3: +1.1% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +7.7% | [-8.0, +23.5] | [+nan, +nan] | 0.101 | S3: +7.7% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +4.6% | [-12.4, +21.7] | [+nan, +nan] | 0.18 | S3: +4.6% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +36.9% | [+13.9, +59.9] | [+nan, +nan] | 0.0312 | S3: +36.9% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | -0.1% | [-12.5, +12.4] | [+nan, +nan] | 0.949 | S3: -0.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +48.9% | [+28.6, +69.2] | [+nan, +nan] | 0.0208 | S3: +48.9% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +72.3% | [-205.6, +350.3] | [+nan, +nan] | 0.187 | S3: +72.3% |

## Point: rate=200/s, mrpc=2

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 3663.1 | 385.2 | [202.5, 7123.6] |
| mtls1.3-postquantum-full | 2 | 4673.1 | 462.5 | [517.5, 8828.6] |
| mtls1.3-x25519 | 2 | 3470.1 | 392.5 | [-56.6, 6996.7] |
| mtls1.3-x25519-full | 2 | 4491.4 | 395.2 | [940.6, 8042.1] |
| plaintext | 2 | 2502.5 | 199.0 | [714.7, 4290.3] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 201.8 | 2.1 | [183.3, 220.2] |
| mtls1.3-postquantum-full | 2 | 202.6 | 3.5 | [170.8, 234.4] |
| mtls1.3-x25519 | 2 | 203.3 | 5.2 | [157.0, 249.7] |
| mtls1.3-x25519-full | 2 | 203.2 | 4.7 | [160.7, 245.8] |
| plaintext | 2 | 201.7 | 2.0 | [183.9, 219.5] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 4.2 | 0.2 | [2.5, 5.8] |
| mtls1.3-postquantum-full | 2 | 5.1 | 0.5 | [0.5, 9.6] |
| mtls1.3-x25519 | 2 | 3.9 | 0.2 | [2.0, 5.8] |
| mtls1.3-x25519-full | 2 | 4.8 | 0.5 | [0.1, 9.6] |
| plaintext | 2 | 2.8 | 0.1 | [2.1, 3.6] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 11.7 | 5.7 | [-39.6, 63.1] |
| mtls1.3-postquantum-full | 2 | 17.0 | 11.5 | [-86.3, 120.3] |
| mtls1.3-x25519 | 2 | 11.2 | 8.3 | [-63.0, 85.5] |
| mtls1.3-x25519-full | 2 | 13.6 | 8.0 | [-58.0, 85.2] |
| plaintext | 2 | 6.5 | 3.4 | [-24.4, 37.4] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +38.5% | [-3.5, +80.5] | [+nan, +nan] | 0.0546 | S3: +38.5% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | +0.8% | [-13.3, +14.9] | [+nan, +nan] | 0.599 | S3: +0.8% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +38.1% | [+9.4, +66.9] | [+nan, +nan] | 0.0378 | S3: +38.1% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | +62.0% | [-310.0, +434.0] | [+nan, +nan] | 0.281 | S3: +62.0% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +79.4% | [+65.7, +93.1] | [+nan, +nan] | 0.00865 | S3: +79.4% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | +0.8% | [-11.5, +13.0] | [+nan, +nan] | 0.573 | S3: +0.8% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +70.5% | [-51.0, +192.1] | [+nan, +nan] | 0.0858 | S3: +70.5% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +105.2% | [-21.1, +231.5] | [+nan, +nan] | 0.06 | S3: +105.2% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +29.6% | [+0.2, +59.0] | [+nan, +nan] | 0.0496 | S3: +29.6% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | -0.0% | [-1.9, +1.8] | [+nan, +nan] | 0.804 | S3: -0.0% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +23.4% | [-38.9, +85.7] | [+nan, +nan] | 0.132 | S3: +23.4% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +29.8% | [-190.3, +249.9] | [+nan, +nan] | 0.335 | S3: +29.8% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +4.0% | [-6.3, +14.3] | [+nan, +nan] | 0.128 | S3: +4.0% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -0.3% | [-5.6, +4.9] | [+nan, +nan] | 0.587 | S3: -0.3% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +4.4% | [-4.6, +13.5] | [+nan, +nan] | 0.102 | S3: +4.4% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +21.1% | [-101.0, +143.2] | [+nan, +nan] | 0.272 | S3: +21.1% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +5.6% | [-2.0, +13.2] | [+nan, +nan] | 0.0677 | S3: +5.6% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | -0.8% | [-14.3, +12.8] | [+nan, +nan] | 0.603 | S3: -0.8% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +6.6% | [-2.7, +15.8] | [+nan, +nan] | 0.0704 | S3: +6.6% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +17.3% | [-300.1, +334.8] | [+nan, +nan] | 0.614 | S3: +17.3% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +27.6% | [+20.5, +34.7] | [+nan, +nan] | 0.0129 | S3: +27.6% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.4% | [-6.2, +7.0] | [+nan, +nan] | 0.568 | S3: +0.4% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +20.9% | [-40.2, +82.0] | [+nan, +nan] | 0.144 | S3: +20.9% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +37.3% | [-242.0, +316.6] | [+nan, +nan] | 0.339 | S3: +37.3% |

## Point: rate=200/s, mrpc=5

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 2647.8 | 297.5 | [-25.0, 5320.5] |
| mtls1.3-postquantum-full | 2 | 3059.6 | 315.7 | [222.9, 5896.2] |
| mtls1.3-x25519 | 2 | 2589.3 | 269.2 | [170.7, 5008.0] |
| mtls1.3-x25519-full | 2 | 3001.2 | 312.0 | [197.5, 5804.8] |
| plaintext | 2 | 2055.1 | 230.5 | [-16.0, 4126.2] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 203.2 | 4.5 | [163.1, 243.2] |
| mtls1.3-postquantum-full | 2 | 201.4 | 2.3 | [180.5, 222.4] |
| mtls1.3-x25519 | 2 | 201.5 | 2.3 | [181.2, 221.8] |
| mtls1.3-x25519-full | 2 | 203.3 | 4.7 | [160.8, 245.9] |
| plaintext | 2 | 201.8 | 2.3 | [180.8, 222.7] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 2.7 | 0.1 | [1.5, 4.0] |
| mtls1.3-postquantum-full | 2 | 2.8 | 0.1 | [1.4, 4.1] |
| mtls1.3-x25519 | 2 | 2.7 | 0.1 | [1.5, 4.0] |
| mtls1.3-x25519-full | 2 | 2.8 | 0.2 | [1.4, 4.2] |
| plaintext | 2 | 2.6 | 0.1 | [1.5, 3.7] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 9.7 | 4.9 | [-34.0, 53.5] |
| mtls1.3-postquantum-full | 2 | 12.0 | 6.0 | [-42.0, 66.1] |
| mtls1.3-x25519 | 2 | 9.2 | 4.7 | [-33.2, 51.5] |
| mtls1.3-x25519-full | 2 | 11.8 | 6.1 | [-42.6, 66.2] |
| plaintext | 2 | 5.9 | 3.2 | [-23.3, 35.1] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +26.1% | [+16.7, +35.4] | [+nan, +nan] | 0.018 | S3: +26.1% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | -0.1% | [-0.4, +0.2] | [+nan, +nan] | 0.121 | S3: -0.1% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +5.7% | [+3.1, +8.3] | [+nan, +nan] | 0.023 | S3: +5.7% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | +57.2% | [-3.4, +117.8] | [+nan, +nan] | 0.053 | S3: +57.2% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +46.1% | [+35.3, +56.9] | [+nan, +nan] | 0.0118 | S3: +46.1% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | +0.8% | [-9.8, +11.4] | [+nan, +nan] | 0.52 | S3: +0.8% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +6.9% | [-1.6, +15.4] | [+nan, +nan] | 0.0613 | S3: +6.9% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +102.8% | [+21.5, +184.1] | [+nan, +nan] | 0.0396 | S3: +102.8% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +15.9% | [+15.9, +15.9] | [+nan, +nan] | 4.27e-05 | S3: +15.9% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +0.9% | [-10.0, +11.9] | [+nan, +nan] | 0.482 | S3: +0.9% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +1.2% | [-4.4, +6.7] | [+nan, +nan] | 0.227 | S3: +1.2% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +29.0% | [+27.1, +31.0] | [+nan, +nan] | 0.00337 | S3: +29.0% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +2.0% | [+1.2, +2.7] | [+nan, +nan] | 0.0185 | S3: +2.0% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -0.9% | [-11.4, +9.5] | [+nan, +nan] | 0.463 | S3: -0.9% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +0.1% | [-1.9, +2.1] | [+nan, +nan] | 0.645 | S3: +0.1% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +2.5% | [-12.3, +17.3] | [+nan, +nan] | 0.278 | S3: +2.5% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +2.2% | [-5.5, +10.0] | [+nan, +nan] | 0.171 | S3: +2.2% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +0.8% | [-8.9, +10.5] | [+nan, +nan] | 0.48 | S3: +0.8% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | -0.3% | [-0.7, +0.1] | [+nan, +nan] | 0.0667 | S3: -0.3% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +6.9% | [-9.8, +23.7] | [+nan, +nan] | 0.12 | S3: +6.9% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +15.6% | [+6.0, +25.2] | [+nan, +nan] | 0.0307 | S3: +15.6% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | -0.8% | [-10.0, +8.4] | [+nan, +nan] | 0.459 | S3: -0.8% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +1.6% | [-1.5, +4.7] | [+nan, +nan] | 0.098 | S3: +1.6% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +23.6% | [+23.3, +24.0] | [+nan, +nan] | 0.000754 | S3: +23.6% |

## Point: rate=300/s, mrpc=0

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 1975.0 | 7.9 | [1903.8, 2046.2] |
| mtls1.3-postquantum-full | 2 | 1989.0 | 5.6 | [1938.9, 2039.2] |
| mtls1.3-x25519 | 2 | 1964.0 | 4.2 | [1926.5, 2001.4] |
| mtls1.3-x25519-full | 2 | 1973.8 | 0.1 | [1973.2, 1974.5] |
| plaintext | 2 | 1843.4 | 4.2 | [1805.3, 1881.5] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 300.4 | 0.5 | [295.9, 304.8] |
| mtls1.3-postquantum-full | 2 | 300.7 | 0.3 | [298.2, 303.2] |
| mtls1.3-x25519 | 2 | 300.6 | 0.8 | [293.7, 307.6] |
| mtls1.3-x25519-full | 2 | 300.9 | 1.6 | [286.9, 314.9] |
| plaintext | 2 | 300.5 | 0.8 | [292.9, 308.1] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 2.4 | 0.0 | [2.3, 2.5] |
| mtls1.3-postquantum-full | 2 | 2.4 | 0.0 | [2.3, 2.5] |
| mtls1.3-x25519 | 2 | 2.4 | 0.0 | [2.4, 2.4] |
| mtls1.3-x25519-full | 2 | 2.4 | 0.0 | [2.3, 2.5] |
| plaintext | 2 | 2.3 | 0.0 | [2.3, 2.4] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 8.3 | 0.6 | [3.0, 13.7] |
| mtls1.3-postquantum-full | 2 | 7.8 | 0.2 | [5.6, 10.0] |
| mtls1.3-x25519 | 2 | 8.1 | 0.4 | [4.4, 11.8] |
| mtls1.3-x25519-full | 2 | 8.2 | 0.5 | [4.2, 12.3] |
| plaintext | 2 | 7.3 | 0.3 | [4.4, 10.1] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +6.5% | [+2.3, +10.8] | [+nan, +nan] | 0.0324 | S3: +6.5% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | +0.0% | [-0.2, +0.3] | [+nan, +nan] | 0.206 | S3: +0.0% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +2.8% | [+0.9, +4.8] | [+nan, +nan] | 0.0341 | S3: +2.8% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | +11.3% | [-83.3, +105.8] | [+nan, +nan] | 0.371 | S3: +11.3% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +7.1% | [+4.8, +9.3] | [+nan, +nan] | 0.0159 | S3: +7.1% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | +0.1% | [-2.0, +2.2] | [+nan, +nan] | 0.571 | S3: +0.1% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +2.6% | [-0.0, +5.3] | [+nan, +nan] | 0.0504 | S3: +2.6% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +13.2% | [+1.8, +24.7] | [+nan, +nan] | 0.0433 | S3: +13.2% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +0.5% | [-1.4, +2.4] | [+nan, +nan] | 0.182 | S3: +0.5% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +0.1% | [-2.2, +2.4] | [+nan, +nan] | 0.729 | S3: +0.1% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | -0.2% | [-4.7, +4.2] | [+nan, +nan] | 0.656 | S3: -0.2% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +2.3% | [-94.9, +99.5] | [+nan, +nan] | 0.816 | S3: +2.3% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +0.8% | [-1.8, +3.3] | [+nan, +nan] | 0.164 | S3: +0.8% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -0.1% | [-3.9, +3.7] | [+nan, +nan] | 0.863 | S3: -0.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +0.6% | [-7.6, +8.8] | [+nan, +nan] | 0.539 | S3: +0.6% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -5.4% | [-25.6, +14.8] | [+nan, +nan] | 0.182 | S3: -5.4% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +0.6% | [-5.0, +6.1] | [+nan, +nan] | 0.419 | S3: +0.6% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | -0.1% | [-0.9, +0.7] | [+nan, +nan] | 0.374 | S3: -0.1% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +0.1% | [-3.1, +3.4] | [+nan, +nan] | 0.668 | S3: +0.1% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +3.0% | [-16.0, +21.9] | [+nan, +nan] | 0.295 | S3: +3.0% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.7% | [-0.4, +1.8] | [+nan, +nan] | 0.0762 | S3: +0.7% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.1% | [-0.5, +0.8] | [+nan, +nan] | 0.258 | S3: +0.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.2% | [-6.7, +7.2] | [+nan, +nan] | 0.764 | S3: +0.2% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | -6.1% | [-92.6, +80.4] | [+nan, +nan] | 0.536 | S3: -6.1% |

## Point: rate=300/s, mrpc=1

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 6495.2 | 145.2 | [5191.0, 7799.5] |
| mtls1.3-postquantum-full | 2 | 7934.9 | 18.4 | [7769.7, 8100.1] |
| mtls1.3-x25519 | 2 | 6207.4 | 40.4 | [5844.0, 6570.8] |
| mtls1.3-x25519-full | 2 | 7265.4 | 423.9 | [3456.8, 11074.1] |
| plaintext | 2 | 3828.4 | 344.9 | [730.0, 6926.9] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 300.6 | 1.0 | [291.7, 309.5] |
| mtls1.3-postquantum-full | 2 | 299.4 | 0.7 | [293.0, 305.8] |
| mtls1.3-x25519 | 2 | 300.3 | 0.3 | [297.8, 302.8] |
| mtls1.3-x25519-full | 2 | 299.5 | 0.2 | [297.5, 301.4] |
| plaintext | 2 | 300.6 | 0.3 | [298.1, 303.1] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 6.5 | 0.2 | [4.7, 8.3] |
| mtls1.3-postquantum-full | 2 | 10.4 | 0.2 | [8.9, 11.8] |
| mtls1.3-x25519 | 2 | 6.3 | 0.0 | [5.9, 6.7] |
| mtls1.3-x25519-full | 2 | 9.4 | 0.3 | [6.7, 12.2] |
| plaintext | 2 | 3.3 | 0.1 | [2.3, 4.3] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 104.5 | 1.4 | [91.5, 117.4] |
| mtls1.3-postquantum-full | 2 | 226.5 | 69.6 | [-399.3, 852.2] |
| mtls1.3-x25519 | 2 | 100.3 | 2.4 | [78.4, 122.3] |
| mtls1.3-x25519-full | 2 | 407.8 | 26.1 | [173.6, 642.0] |
| plaintext | 2 | 52.2 | 48.2 | [-380.6, 485.1] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +62.8% | [-78.4, +204.1] | [+nan, +nan] | 0.111 | S3: +62.8% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | -0.1% | [-0.1, -0.1] | [+nan, +nan] | 0.000424 | S3: -0.1% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +90.1% | [+19.6, +160.7] | [+nan, +nan] | 0.0392 | S3: +90.1% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | +230.2% | [-2463.0, +2923.4] | [+nan, +nan] | 0.474 | S3: +230.2% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +90.0% | [+35.7, +144.4] | [+nan, +nan] | 0.0302 | S3: +90.0% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | -0.4% | [-1.9, +1.1] | [+nan, +nan] | 0.188 | S3: -0.4% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +184.6% | [+179.8, +189.4] | [+nan, +nan] | 0.0013 | S3: +184.6% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +1217.5% | [-9248.2, +11683.2] | [+nan, +nan] | 0.379 | S3: +1217.5% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +17.1% | [-51.1, +85.3] | [+nan, +nan] | 0.194 | S3: +17.1% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | -0.3% | [-1.8, +1.2] | [+nan, +nan] | 0.248 | S3: -0.3% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +49.8% | [-3.3, +102.9] | [+nan, +nan] | 0.0533 | S3: +49.8% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +306.3% | [+161.8, +450.9] | [+nan, +nan] | 0.0236 | S3: +306.3% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +9.4% | [-50.2, +69.0] | [+nan, +nan] | 0.295 | S3: +9.4% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -0.0% | [-2.8, +2.7] | [+nan, +nan] | 0.951 | S3: -0.0% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +10.1% | [-7.0, +27.2] | [+nan, +nan] | 0.0842 | S3: +10.1% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -43.8% | [-229.5, +141.9] | [+nan, +nan] | 0.205 | S3: -43.8% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +4.6% | [-10.3, +19.5] | [+nan, +nan] | 0.158 | S3: +4.6% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +0.1% | [-2.0, +2.2] | [+nan, +nan] | 0.656 | S3: +0.1% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +3.2% | [-19.6, +25.9] | [+nan, +nan] | 0.327 | S3: +3.2% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +4.2% | [-31.5, +39.8] | [+nan, +nan] | 0.378 | S3: +4.2% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +22.2% | [+0.2, +44.2] | [+nan, +nan] | 0.0496 | S3: +22.2% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | -0.4% | [-1.2, +0.4] | [+nan, +nan] | 0.104 | S3: -0.4% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +59.9% | [-7.2, +127.0] | [+nan, +nan] | 0.056 | S3: +59.9% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +116.4% | [-456.0, +688.7] | [+nan, +nan] | 0.235 | S3: +116.4% |

## Point: rate=300/s, mrpc=2

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 3813.0 | 422.8 | [13.8, 7612.2] |
| mtls1.3-postquantum-full | 2 | 4462.5 | 408.0 | [796.8, 8128.2] |
| mtls1.3-x25519 | 2 | 3549.6 | 408.4 | [-120.0, 7219.2] |
| mtls1.3-x25519-full | 2 | 4351.9 | 428.9 | [498.8, 8205.1] |
| plaintext | 2 | 2393.8 | 258.0 | [76.2, 4711.4] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 300.6 | 0.6 | [294.9, 306.4] |
| mtls1.3-postquantum-full | 2 | 301.0 | 0.9 | [292.7, 309.2] |
| mtls1.3-x25519 | 2 | 300.6 | 1.1 | [291.1, 310.2] |
| mtls1.3-x25519-full | 2 | 300.5 | 0.4 | [296.7, 304.3] |
| plaintext | 2 | 300.4 | 0.1 | [299.1, 301.7] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 4.3 | 0.3 | [2.0, 6.6] |
| mtls1.3-postquantum-full | 2 | 5.4 | 0.4 | [1.5, 9.4] |
| mtls1.3-x25519 | 2 | 3.9 | 0.2 | [2.1, 5.7] |
| mtls1.3-x25519-full | 2 | 5.3 | 0.5 | [0.5, 10.0] |
| plaintext | 2 | 2.7 | 0.1 | [2.0, 3.5] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 18.2 | 15.4 | [-120.2, 156.6] |
| mtls1.3-postquantum-full | 2 | 24.1 | 19.0 | [-146.9, 195.2] |
| mtls1.3-x25519 | 2 | 14.7 | 11.2 | [-85.9, 115.4] |
| mtls1.3-x25519-full | 2 | 24.3 | 20.4 | [-159.0, 207.6] |
| plaintext | 2 | 6.6 | 3.9 | [-28.8, 42.0] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +48.2% | [+38.4, +58.0] | [+nan, +nan] | 0.0102 | S3: +48.2% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | +0.1% | [-2.7, +2.8] | [+nan, +nan] | 0.766 | S3: +0.1% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +43.3% | [+15.3, +71.3] | [+nan, +nan] | 0.0324 | S3: +43.3% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | +109.6% | [-292.1, +511.3] | [+nan, +nan] | 0.179 | S3: +109.6% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +81.9% | [+66.8, +97.0] | [+nan, +nan] | 0.00926 | S3: +81.9% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | +0.0% | [-0.8, +0.9] | [+nan, +nan] | 0.705 | S3: +0.0% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +92.0% | [-30.7, +214.6] | [+nan, +nan] | 0.0666 | S3: +92.0% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +235.3% | [-745.1, +1215.8] | [+nan, +nan] | 0.202 | S3: +235.3% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +22.7% | [+4.4, +41.0] | [+nan, +nan] | 0.0403 | S3: +22.7% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | -0.0% | [-1.9, +1.9] | [+nan, +nan] | 0.796 | S3: -0.0% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +33.9% | [-25.5, +93.3] | [+nan, +nan] | 0.0872 | S3: +33.9% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +58.0% | [-106.9, +222.9] | [+nan, +nan] | 0.14 | S3: +58.0% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +2.6% | [-4.0, +9.2] | [+nan, +nan] | 0.126 | S3: +2.6% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +0.1% | [-1.3, +1.6] | [+nan, +nan] | 0.421 | S3: +0.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +3.7% | [-14.3, +21.6] | [+nan, +nan] | 0.233 | S3: +3.7% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +2.7% | [-68.4, +73.9] | [+nan, +nan] | 0.71 | S3: +2.7% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +7.4% | [+3.4, +11.5] | [+nan, +nan] | 0.0272 | S3: +7.4% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +0.0% | [-1.3, +1.3] | [+nan, +nan] | 0.998 | S3: +0.0% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +9.9% | [+2.1, +17.7] | [+nan, +nan] | 0.0393 | S3: +9.9% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +18.1% | [-115.2, +151.4] | [+nan, +nan] | 0.335 | S3: +18.1% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +17.2% | [-3.4, +37.8] | [+nan, +nan] | 0.06 | S3: +17.2% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.1% | [-0.7, +0.9] | [+nan, +nan] | 0.374 | S3: +0.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +26.2% | [+1.0, +51.4] | [+nan, +nan] | 0.0481 | S3: +26.2% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +37.6% | [-69.4, +144.7] | [+nan, +nan] | 0.14 | S3: +37.6% |

## Point: rate=300/s, mrpc=5

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 2925.8 | 24.5 | [2705.4, 3146.3] |
| mtls1.3-postquantum-full | 2 | 3168.7 | 5.4 | [3119.7, 3217.6] |
| mtls1.3-x25519 | 2 | 2855.8 | 44.9 | [2452.3, 3259.2] |
| mtls1.3-x25519-full | 2 | 3093.9 | 16.3 | [2947.2, 3240.7] |
| plaintext | 2 | 2142.3 | 10.3 | [2050.2, 2234.5] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 300.6 | 0.4 | [297.5, 303.8] |
| mtls1.3-postquantum-full | 2 | 301.1 | 0.8 | [294.2, 308.1] |
| mtls1.3-x25519 | 2 | 300.9 | 0.9 | [292.6, 309.1] |
| mtls1.3-x25519-full | 2 | 300.8 | 0.9 | [292.5, 309.0] |
| plaintext | 2 | 300.6 | 0.8 | [293.6, 307.5] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 2.8 | 0.0 | [2.5, 3.1] |
| mtls1.3-postquantum-full | 2 | 2.8 | 0.0 | [2.6, 3.0] |
| mtls1.3-x25519 | 2 | 2.8 | 0.0 | [2.4, 3.2] |
| mtls1.3-x25519-full | 2 | 2.8 | 0.0 | [2.6, 3.1] |
| plaintext | 2 | 2.5 | 0.0 | [2.4, 2.7] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 18.8 | 0.2 | [17.2, 20.4] |
| mtls1.3-postquantum-full | 2 | 24.0 | 1.7 | [8.4, 39.6] |
| mtls1.3-x25519 | 2 | 17.6 | 0.0 | [17.3, 17.9] |
| mtls1.3-x25519-full | 2 | 21.2 | 2.3 | [0.6, 41.8] |
| plaintext | 2 | 8.4 | 0.4 | [4.8, 12.1] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +33.3% | [+20.2, +46.4] | [+nan, +nan] | 0.0197 | S3: +33.3% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | +0.1% | [-0.3, +0.5] | [+nan, +nan] | 0.204 | S3: +0.1% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +10.3% | [+1.1, +19.5] | [+nan, +nan] | 0.0445 | S3: +10.3% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | +109.0% | [+14.3, +203.7] | [+nan, +nan] | 0.0434 | S3: +109.0% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +44.4% | [+43.8, +45.1] | [+nan, +nan] | 0.000722 | S3: +44.4% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | +0.1% | [-0.4, +0.5] | [+nan, +nan] | 0.294 | S3: +0.1% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +10.9% | [+6.7, +15.0] | [+nan, +nan] | 0.0192 | S3: +10.9% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +151.2% | [+16.8, +285.6] | [+nan, +nan] | 0.0445 | S3: +151.2% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +8.3% | [-1.8, +18.5] | [+nan, +nan] | 0.0608 | S3: +8.3% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | -0.0% | [-0.0, -0.0] | [+nan, +nan] | 0.00138 | S3: -0.0% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +0.5% | [-4.1, +5.1] | [+nan, +nan] | 0.414 | S3: +0.5% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +20.5% | [-98.3, +139.4] | [+nan, +nan] | 0.272 | S3: +20.5% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +2.4% | [-0.9, +5.7] | [+nan, +nan] | 0.0677 | S3: +2.4% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +0.1% | [-0.3, +0.6] | [+nan, +nan] | 0.157 | S3: +0.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +0.7% | [-14.9, +16.3] | [+nan, +nan] | 0.672 | S3: +0.7% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +14.2% | [-170.0, +198.4] | [+nan, +nan] | 0.507 | S3: +14.2% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +2.5% | [-4.3, +9.2] | [+nan, +nan] | 0.135 | S3: +2.5% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | -0.1% | [-1.8, +1.6] | [+nan, +nan] | 0.706 | S3: -0.1% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +0.1% | [-1.9, +2.1] | [+nan, +nan] | 0.583 | S3: +0.1% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +6.8% | [-3.9, +17.5] | [+nan, +nan] | 0.0784 | S3: +6.8% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +8.3% | [+1.8, +14.8] | [+nan, +nan] | 0.0391 | S3: +8.3% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.2% | [-1.1, +1.4] | [+nan, +nan] | 0.344 | S3: +0.2% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +1.1% | [-17.2, +19.3] | [+nan, +nan] | 0.597 | S3: +1.1% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +27.7% | [-65.8, +121.2] | [+nan, +nan] | 0.166 | S3: +27.7% |

## Point: rate=400/s, mrpc=0

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 1946.5 | 4.6 | [1905.2, 1987.7] |
| mtls1.3-postquantum-full | 2 | 1928.4 | 15.7 | [1787.4, 2069.4] |
| mtls1.3-x25519 | 2 | 1799.6 | 206.7 | [-57.5, 3656.6] |
| mtls1.3-x25519-full | 2 | 1977.5 | 45.1 | [1572.2, 2382.8] |
| plaintext | 2 | 1679.6 | 193.6 | [-59.9, 3419.1] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 408.8 | 12.0 | [301.4, 516.1] |
| mtls1.3-postquantum-full | 2 | 408.8 | 11.6 | [304.6, 513.0] |
| mtls1.3-x25519 | 2 | 408.8 | 11.2 | [308.4, 509.2] |
| mtls1.3-x25519-full | 2 | 408.1 | 10.4 | [314.8, 501.5] |
| plaintext | 2 | 404.6 | 5.2 | [358.3, 451.0] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 2.4 | 0.1 | [1.9, 2.9] |
| mtls1.3-postquantum-full | 2 | 2.4 | 0.1 | [1.8, 3.0] |
| mtls1.3-x25519 | 2 | 2.3 | 0.1 | [1.3, 3.4] |
| mtls1.3-x25519-full | 2 | 2.4 | 0.1 | [1.6, 3.2] |
| plaintext | 2 | 2.3 | 0.1 | [1.4, 3.2] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 9.0 | 1.0 | [0.3, 17.7] |
| mtls1.3-postquantum-full | 2 | 9.6 | 0.5 | [5.4, 13.8] |
| mtls1.3-x25519 | 2 | 6.0 | 3.8 | [-28.3, 40.3] |
| mtls1.3-x25519-full | 2 | 9.9 | 1.5 | [-3.2, 23.0] |
| plaintext | 2 | 7.0 | 2.5 | [-15.6, 29.6] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +7.1% | [+6.7, +7.5] | [+nan, +nan] | 0.00281 | S3: +7.1% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | +1.0% | [-12.2, +14.2] | [+nan, +nan] | 0.508 | S3: +1.0% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +2.1% | [-2.4, +6.7] | [+nan, +nan] | 0.106 | S3: +2.1% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | -19.0% | [-247.4, +209.3] | [+nan, +nan] | 0.482 | S3: -19.0% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +18.4% | [-80.1, +116.8] | [+nan, +nan] | 0.254 | S3: +18.4% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | +0.9% | [-10.7, +12.4] | [+nan, +nan] | 0.518 | S3: +0.9% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +5.2% | [-2.3, +12.6] | [+nan, +nan] | 0.0719 | S3: +5.2% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +47.0% | [-239.8, +333.9] | [+nan, +nan] | 0.285 | S3: +47.0% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +10.5% | [-81.0, +102.0] | [+nan, +nan] | 0.383 | S3: +10.5% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | -0.2% | [-1.8, +1.5] | [+nan, +nan] | 0.445 | S3: -0.2% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +3.0% | [-8.9, +14.8] | [+nan, +nan] | 0.193 | S3: +3.0% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +97.5% | [-814.1, +1009.2] | [+nan, +nan] | 0.404 | S3: +97.5% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -2.5% | [-15.3, +10.4] | [+nan, +nan] | 0.248 | S3: -2.5% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +0.2% | [-2.5, +2.8] | [+nan, +nan] | 0.587 | S3: +0.2% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -1.5% | [-8.6, +5.7] | [+nan, +nan] | 0.23 | S3: -1.5% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -2.7% | [-88.9, +83.5] | [+nan, +nan] | 0.76 | S3: -2.7% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +8.9% | [-105.8, +123.6] | [+nan, +nan] | 0.505 | S3: +8.9% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | -0.0% | [-1.7, +1.7] | [+nan, +nan] | 0.93 | S3: -0.0% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +1.9% | [-22.5, +26.2] | [+nan, +nan] | 0.511 | S3: +1.9% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +82.4% | [-815.7, +980.5] | [+nan, +nan] | 0.451 | S3: +82.4% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | -0.9% | [-10.3, +8.4] | [+nan, +nan] | 0.427 | S3: -0.9% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +0.0% | [-0.8, +0.8] | [+nan, +nan] | 0.862 | S3: +0.0% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | -0.4% | [-5.5, +4.8] | [+nan, +nan] | 0.509 | S3: -0.4% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +6.4% | [-49.7, +62.4] | [+nan, +nan] | 0.386 | S3: +6.4% |

## Point: rate=400/s, mrpc=1

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| plaintext | 2 | 4644.0 | 39.8 | [4286.3, 5001.6] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| plaintext | 2 | 407.8 | 12.2 | [297.8, 517.7] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| plaintext | 2 | 4.8 | 0.2 | [2.9, 6.8] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| plaintext | 2 | 194.7 | 59.0 | [-335.3, 724.6] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|

## Point: rate=400/s, mrpc=2

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 4045.9 | 50.9 | [3588.5, 4503.3] |
| mtls1.3-postquantum-full | 2 | 4597.9 | 3.5 | [4566.7, 4629.0] |
| mtls1.3-x25519 | 2 | 3927.2 | 52.8 | [3452.6, 4401.7] |
| mtls1.3-x25519-full | 2 | 4474.2 | 16.1 | [4329.3, 4619.1] |
| plaintext | 2 | 2569.4 | 8.3 | [2494.4, 2644.4] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 408.5 | 10.1 | [317.7, 499.4] |
| mtls1.3-postquantum-full | 2 | 408.5 | 10.2 | [317.0, 500.0] |
| mtls1.3-x25519 | 2 | 404.4 | 4.5 | [364.3, 444.4] |
| mtls1.3-x25519-full | 2 | 404.2 | 4.6 | [363.0, 445.5] |
| plaintext | 2 | 408.7 | 9.6 | [322.3, 495.1] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 4.8 | 0.1 | [3.7, 6.0] |
| mtls1.3-postquantum-full | 2 | 6.3 | 0.3 | [4.0, 8.7] |
| mtls1.3-x25519 | 2 | 4.6 | 0.1 | [3.5, 5.6] |
| mtls1.3-x25519-full | 2 | 6.2 | 0.2 | [4.3, 8.0] |
| plaintext | 2 | 2.9 | 0.1 | [2.1, 3.8] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 45.3 | 1.0 | [36.6, 54.0] |
| mtls1.3-postquantum-full | 2 | 61.5 | 4.2 | [23.7, 99.2] |
| mtls1.3-x25519 | 2 | 45.6 | 2.1 | [26.8, 64.5] |
| mtls1.3-x25519-full | 2 | 62.5 | 0.9 | [54.5, 70.5] |
| plaintext | 2 | 13.2 | 0.7 | [7.1, 19.3] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +52.8% | [+38.8, +66.9] | [+nan, +nan] | 0.0133 | S3: +52.8% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | -1.0% | [-12.2, +10.1] | [+nan, +nan] | 0.443 | S3: -1.0% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +55.0% | [+46.7, +63.3] | [+nan, +nan] | 0.00753 | S3: +55.0% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | +245.8% | [-55.9, +547.6] | [+nan, +nan] | 0.0613 | S3: +245.8% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +74.1% | [+73.6, +74.7] | [+nan, +nan] | 0.000376 | S3: +74.1% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | -1.1% | [-11.9, +9.7] | [+nan, +nan] | 0.426 | S3: -1.1% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +108.8% | [+105.5, +112.1] | [+nan, +nan] | 0.00152 | S3: +108.8% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +372.6% | [+215.2, +530.1] | [+nan, +nan] | 0.0212 | S3: +372.6% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +13.9% | [+3.9, +24.0] | [+nan, +nan] | 0.0362 | S3: +13.9% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | -0.0% | [-0.3, +0.3] | [+nan, +nan] | 0.5 | S3: -0.0% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +34.7% | [+25.4, +44.0] | [+nan, +nan] | 0.0134 | S3: +34.7% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +37.1% | [-37.0, +111.1] | [+nan, +nan] | 0.0993 | S3: +37.1% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +2.8% | [-1.3, +6.8] | [+nan, +nan] | 0.0726 | S3: +2.8% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +1.0% | [-11.3, +13.4] | [+nan, +nan] | 0.476 | S3: +1.0% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +2.9% | [-4.8, +10.6] | [+nan, +nan] | 0.13 | S3: +2.9% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -1.6% | [-74.6, +71.5] | [+nan, +nan] | 0.829 | S3: -1.6% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +3.0% | [-21.1, +27.1] | [+nan, +nan] | 0.355 | S3: +3.0% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +1.0% | [-11.4, +13.5] | [+nan, +nan] | 0.484 | S3: +1.0% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +5.0% | [+4.2, +5.9] | [+nan, +nan] | 0.00838 | S3: +5.0% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | -0.5% | [-60.7, +59.6] | [+nan, +nan] | 0.928 | S3: -0.5% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +13.7% | [+1.6, +25.7] | [+nan, +nan] | 0.0443 | S3: +13.7% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | -0.0% | [-0.2, +0.1] | [+nan, +nan] | 0.5 | S3: -0.0% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +32.0% | [+14.1, +50.0] | [+nan, +nan] | 0.028 | S3: +32.0% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +35.7% | [-73.7, +145.1] | [+nan, +nan] | 0.151 | S3: +35.7% |

## Point: rate=400/s, mrpc=5

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 2668.1 | 292.8 | [37.2, 5298.9] |
| mtls1.3-postquantum-full | 2 | 2890.3 | 321.6 | [0.9, 5779.7] |
| mtls1.3-x25519 | 2 | 2605.6 | 275.6 | [129.7, 5081.4] |
| mtls1.3-x25519-full | 2 | 2854.0 | 265.4 | [469.0, 5239.0] |
| plaintext | 2 | 1972.9 | 218.5 | [9.8, 3936.0] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 404.1 | 4.3 | [365.3, 442.8] |
| mtls1.3-postquantum-full | 2 | 408.6 | 11.5 | [305.7, 511.5] |
| mtls1.3-x25519 | 2 | 406.1 | 2.5 | [383.9, 428.4] |
| mtls1.3-x25519-full | 2 | 407.0 | 8.7 | [328.8, 485.1] |
| plaintext | 2 | 404.4 | 5.2 | [357.4, 451.4] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 2.8 | 0.3 | [0.1, 5.5] |
| mtls1.3-postquantum-full | 2 | 2.9 | 0.3 | [0.1, 5.6] |
| mtls1.3-x25519 | 2 | 2.8 | 0.3 | [0.4, 5.1] |
| mtls1.3-x25519-full | 2 | 2.9 | 0.3 | [0.1, 5.7] |
| plaintext | 2 | 2.5 | 0.1 | [1.2, 3.8] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 2 | 24.7 | 22.8 | [-180.3, 229.7] |
| mtls1.3-postquantum-full | 2 | 28.4 | 25.0 | [-196.5, 253.3] |
| mtls1.3-x25519 | 2 | 18.3 | 14.2 | [-108.9, 145.5] |
| mtls1.3-x25519-full | 2 | 26.8 | 22.9 | [-178.9, 232.4] |
| plaintext | 2 | 6.9 | 4.3 | [-32.1, 45.9] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 2 | +32.1% | [+26.1, +38.1] | [+nan, +nan] | 0.0093 | S3: +32.1% |
| window_rps | mtls1.3-x25519 | plaintext | 2 | +0.4% | [-5.7, +6.6] | [+nan, +nan] | 0.534 | S3: +0.4% |
| p50_ms | mtls1.3-x25519 | plaintext | 2 | +11.6% | [-22.8, +46.1] | [+nan, +nan] | 0.146 | S3: +11.6% |
| p99_ms | mtls1.3-x25519 | plaintext | 2 | +150.3% | [-278.7, +579.3] | [+nan, +nan] | 0.141 | S3: +150.3% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 2 | +44.8% | [+21.6, +68.0] | [+nan, +nan] | 0.0259 | S3: +44.8% |
| window_rps | mtls1.3-x25519-full | plaintext | 2 | +0.6% | [-7.0, +8.3] | [+nan, +nan] | 0.487 | S3: +0.6% |
| p50_ms | mtls1.3-x25519-full | plaintext | 2 | +15.0% | [-35.6, +65.5] | [+nan, +nan] | 0.165 | S3: +15.0% |
| p99_ms | mtls1.3-x25519-full | plaintext | 2 | +254.3% | [-725.3, +1233.8] | [+nan, +nan] | 0.187 | S3: +254.3% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +9.6% | [-3.0, +22.2] | [+nan, +nan] | 0.0656 | S3: +9.6% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +0.2% | [-13.6, +13.9] | [+nan, +nan] | 0.888 | S3: +0.2% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +2.9% | [-10.5, +16.4] | [+nan, +nan] | 0.22 | S3: +2.9% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 2 | +39.9% | [-111.6, +191.5] | [+nan, +nan] | 0.185 | S3: +39.9% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +1.2% | [-15.5, +17.9] | [+nan, +nan] | 0.532 | S3: +1.2% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +0.4% | [-5.6, +6.4] | [+nan, +nan] | 0.555 | S3: +0.4% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | -0.7% | [-0.8, -0.6] | [+nan, +nan] | 0.0051 | S3: -0.7% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 2 | +4.4% | [-33.7, +42.5] | [+nan, +nan] | 0.381 | S3: +4.4% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +2.4% | [-1.3, +6.1] | [+nan, +nan] | 0.0774 | S3: +2.4% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 2 | -0.5% | [-4.6, +3.6] | [+nan, +nan] | 0.354 | S3: -0.5% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +0.6% | [-11.2, +12.3] | [+nan, +nan] | 0.641 | S3: +0.6% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 2 | +23.9% | [-235.8, +283.5] | [+nan, +nan] | 0.451 | S3: +23.9% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +8.3% | [+6.8, +9.8] | [+nan, +nan] | 0.00895 | S3: +8.3% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +1.1% | [-14.7, +16.9] | [+nan, +nan] | 0.534 | S3: +1.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +1.6% | [+0.3, +3.0] | [+nan, +nan] | 0.0414 | S3: +1.6% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 2 | +19.2% | [-59.9, +98.4] | [+nan, +nan] | 0.199 | S3: +19.2% |

## TLS session resumption

| setup | handshakes | reused | reused share | conn errors |
|---|---|---|---|---|
| mtls1.3-postquantum | 120541 | 194050 | 80.5% | 0 |
| mtls1.3-postquantum-full | 120624 | 0 | 0.0% | 0 |
| mtls1.3-x25519 | 120555 | 198549 | 82.3% | 0 |
| mtls1.3-x25519-full | 120448 | 0 | 0.0% | 0 |

## Key exchange verification (curve_evidence.csv)

| setup | windows | PASS | FAIL |
|---|---|---|---|
| mtls1.3-postquantum | 32 | 24 | 0 |
| mtls1.3-postquantum-full | 32 | 25 | 0 |
| mtls1.3-x25519 | 32 | 24 | 0 |
| mtls1.3-x25519-full | 32 | 24 | 0 |
