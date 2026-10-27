# Statistical report (mode = grid)

Rejected windows: 29 (k6 errors, dropped iterations, plaintext with handshakes or curve FAIL)

- mtls1.3-x25519-full session=1 run=1: fail_rate=0.0 dropped=9 handshakes=13761
- mtls1.3-postquantum-full session=1 run=1: fail_rate=0.0 dropped=2182 handshakes=15986
- mtls1.3-postquantum session=1 run=1: fail_rate=0.0 dropped=1078 handshakes=16907
- mtls1.3-x25519 session=1 run=1: fail_rate=0.0 dropped=1158 handshakes=16984
- plaintext session=1 run=1: fail_rate=0.0 dropped=46 handshakes=0
- mtls1.3-x25519-full session=1 run=1: fail_rate=0.0 dropped=1891 handshakes=16213
- mtls1.3-postquantum-full session=1 run=2: fail_rate=0.0 dropped=30 handshakes=13777
- mtls1.3-x25519-full session=1 run=2: fail_rate=0.0 dropped=576 handshakes=12924
- mtls1.3-postquantum-full session=1 run=2: fail_rate=0.0 dropped=2078 handshakes=16063
- mtls1.3-x25519 session=1 run=2: fail_rate=0.0 dropped=1128 handshakes=16879
- plaintext session=1 run=2: fail_rate=0.0 dropped=190 handshakes=0
- mtls1.3-x25519-full session=1 run=2: fail_rate=0.0 dropped=2009 handshakes=16148
- mtls1.3-postquantum session=1 run=2: fail_rate=0.0 dropped=1246 handshakes=16802
- mtls1.3-postquantum session=2 run=1: fail_rate=0.0 dropped=1537 handshakes=16529
- mtls1.3-postquantum-full session=2 run=1: fail_rate=0.0 dropped=2221 handshakes=15929
- mtls1.3-x25519 session=2 run=1: fail_rate=0.0 dropped=1188 handshakes=16854
- plaintext session=2 run=1: fail_rate=0.0 dropped=55 handshakes=0
- mtls1.3-x25519-full session=2 run=1: fail_rate=0.0 dropped=2019 handshakes=16160
- mtls1.3-x25519 session=2 run=1: fail_rate=0.0 dropped=13 handshakes=13831
- mtls1.3-postquantum-full session=2 run=1: fail_rate=0.0 dropped=52 handshakes=13729
- mtls1.3-x25519-full session=2 run=1: fail_rate=0.0 dropped=36 handshakes=13756
- mtls1.3-postquantum-full session=2 run=2: fail_rate=0.0 dropped=2241 handshakes=15963
- plaintext session=2 run=2: fail_rate=0.0 dropped=55 handshakes=0
- mtls1.3-x25519-full session=2 run=2: fail_rate=0.0 dropped=2052 handshakes=16100
- mtls1.3-postquantum session=2 run=2: fail_rate=0.0 dropped=1714 handshakes=16410
- mtls1.3-x25519 session=2 run=2: fail_rate=0.0 dropped=1366 handshakes=16680
- plaintext session=2 run=2: fail_rate=5.55524693072e-05 dropped=0 handshakes=0
- mtls1.3-x25519-full session=2 run=2: fail_rate=0.0 dropped=43 handshakes=13745
- mtls1.3-postquantum-full session=2 run=2: fail_rate=0.0 dropped=89 handshakes=13695

## Point: rate=100/s, mrpc=0

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 2255.2 | 12.9 | [2234.7, 2275.6] |
| mtls1.3-postquantum-full | 4 | 2247.1 | 18.6 | [2217.6, 2276.6] |
| mtls1.3-x25519 | 4 | 2234.3 | 28.8 | [2188.6, 2280.1] |
| mtls1.3-x25519-full | 4 | 2232.9 | 17.4 | [2205.2, 2260.6] |
| plaintext | 4 | 2086.9 | 25.5 | [2046.3, 2127.5] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 104.6 | 2.6 | [100.5, 108.8] |
| mtls1.3-postquantum-full | 4 | 106.6 | 2.9 | [101.9, 111.2] |
| mtls1.3-x25519 | 4 | 105.2 | 1.0 | [103.5, 106.8] |
| mtls1.3-x25519-full | 4 | 106.3 | 2.1 | [102.9, 109.7] |
| plaintext | 4 | 105.0 | 1.0 | [103.3, 106.6] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 2.7 | 0.0 | [2.7, 2.8] |
| mtls1.3-postquantum-full | 4 | 2.7 | 0.0 | [2.7, 2.8] |
| mtls1.3-x25519 | 4 | 2.7 | 0.0 | [2.7, 2.8] |
| mtls1.3-x25519-full | 4 | 2.7 | 0.0 | [2.7, 2.8] |
| plaintext | 4 | 2.7 | 0.0 | [2.6, 2.7] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 7.6 | 0.2 | [7.2, 7.9] |
| mtls1.3-postquantum-full | 4 | 7.6 | 0.3 | [7.1, 8.0] |
| mtls1.3-x25519 | 4 | 7.5 | 0.1 | [7.2, 7.7] |
| mtls1.3-x25519-full | 4 | 7.4 | 0.1 | [7.3, 7.6] |
| plaintext | 4 | 7.4 | 0.2 | [7.1, 7.7] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 4 | +7.1% | [+4.7, +9.4] | [+6.2, +7.9] | 0.00241 | S1: +6.2%, S2: +7.9% |
| window_rps | mtls1.3-x25519 | plaintext | 4 | +0.2% | [+0.2, +0.2] | [+0.2, +0.2] | 2.5e-07 | S1: +0.2%, S2: +0.2% |
| p50_ms | mtls1.3-x25519 | plaintext | 4 | +2.5% | [+1.2, +3.8] | [+2.0, +3.0] | 0.00883 | S1: +2.0%, S2: +3.0% |
| p99_ms | mtls1.3-x25519 | plaintext | 4 | +0.7% | [-4.5, +5.9] | [+0.5, +0.9] | 0.699 | S1: +0.5%, S2: +0.9% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 4 | +7.0% | [+4.5, +9.6] | [+6.7, +7.3] | 0.00312 | S1: +6.7%, S2: +7.3% |
| window_rps | mtls1.3-x25519-full | plaintext | 4 | +1.3% | [-2.2, +4.8] | [+0.1, +2.4] | 0.327 | S1: +0.1%, S2: +2.4% |
| p50_ms | mtls1.3-x25519-full | plaintext | 4 | +2.5% | [+1.7, +3.3] | [+2.1, +2.9] | 0.00212 | S1: +2.1%, S2: +2.9% |
| p99_ms | mtls1.3-x25519-full | plaintext | 4 | +0.5% | [-2.9, +3.9] | [-0.6, +1.6] | 0.674 | S1: +1.6%, S2: -0.6% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -0.1% | [-1.2, +1.1] | [-0.6, +0.4] | 0.886 | S1: +0.4%, S2: -0.6% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +1.1% | [-2.4, +4.6] | [-0.0, +2.2] | 0.393 | S1: -0.0%, S2: +2.2% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -0.0% | [-0.8, +0.8] | [-0.1, +0.0] | 0.927 | S1: +0.0%, S2: -0.1% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -0.1% | [-4.8, +4.5] | [-1.5, +1.2] | 0.93 | S1: +1.2%, S2: -1.5% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +0.6% | [+0.2, +1.1] | [+0.5, +0.7] | 0.0176 | S1: +0.5%, S2: +0.7% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +0.3% | [-4.6, +5.1] | [-1.6, +2.2] | 0.866 | S1: -1.6%, S2: +2.2% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +0.3% | [-0.9, +1.5] | [+0.3, +0.3] | 0.507 | S1: +0.3%, S2: +0.3% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +1.9% | [-4.4, +8.3] | [-1.0, +4.8] | 0.401 | S1: -1.0%, S2: +4.8% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +0.9% | [-0.8, +2.6] | [+0.4, +1.5] | 0.177 | S1: +1.5%, S2: +0.4% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -0.5% | [-5.9, +4.9] | [-3.0, +2.0] | 0.798 | S1: -3.0%, S2: +2.0% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +0.4% | [-0.5, +1.3] | [-0.0, +0.9] | 0.235 | S1: +0.9%, S2: -0.0% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +1.3% | [-3.8, +6.4] | [+0.3, +2.3] | 0.48 | S1: +2.3%, S2: +0.3% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -0.4% | [-1.6, +0.8] | [-0.5, -0.2] | 0.413 | S1: -0.5%, S2: -0.2% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +1.9% | [-1.8, +5.5] | [+1.4, +2.4] | 0.201 | S1: +1.4%, S2: +2.4% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -0.2% | [-1.2, +0.9] | [-0.5, +0.2] | 0.649 | S1: -0.5%, S2: +0.2% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +0.5% | [-4.6, +5.6] | [-2.0, +3.0] | 0.781 | S1: -2.0%, S2: +3.0% |

## Point: rate=100/s, mrpc=1

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 5921.7 | 176.0 | [5641.7, 6201.7] |
| mtls1.3-postquantum-full | 4 | 7916.4 | 43.7 | [7846.9, 7985.9] |
| mtls1.3-x25519 | 4 | 5582.9 | 73.2 | [5466.3, 5699.4] |
| mtls1.3-x25519-full | 4 | 7640.5 | 89.9 | [7497.5, 7783.5] |
| plaintext | 4 | 3571.5 | 17.2 | [3544.2, 3598.9] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 106.4 | 2.2 | [102.9, 109.9] |
| mtls1.3-postquantum-full | 4 | 104.8 | 2.7 | [100.5, 109.0] |
| mtls1.3-x25519 | 4 | 106.5 | 2.1 | [103.2, 109.9] |
| mtls1.3-x25519-full | 4 | 106.8 | 3.0 | [102.0, 111.5] |
| plaintext | 4 | 104.7 | 2.7 | [100.4, 108.9] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 5.5 | 0.1 | [5.3, 5.7] |
| mtls1.3-postquantum-full | 4 | 7.5 | 0.1 | [7.4, 7.7] |
| mtls1.3-x25519 | 4 | 5.2 | 0.1 | [5.1, 5.3] |
| mtls1.3-x25519-full | 4 | 7.2 | 0.1 | [7.1, 7.4] |
| plaintext | 4 | 3.6 | 0.0 | [3.6, 3.7] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 17.3 | 0.9 | [15.9, 18.6] |
| mtls1.3-postquantum-full | 4 | 20.3 | 0.6 | [19.4, 21.2] |
| mtls1.3-x25519 | 4 | 15.4 | 0.5 | [14.6, 16.2] |
| mtls1.3-x25519-full | 4 | 20.3 | 1.4 | [18.1, 22.4] |
| plaintext | 4 | 9.4 | 0.2 | [9.0, 9.8] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 4 | +56.3% | [+54.2, +58.4] | [+55.6, +57.1] | 3.66e-06 | S1: +57.1%, S2: +55.6% |
| window_rps | mtls1.3-x25519 | plaintext | 4 | +1.8% | [-4.2, +7.9] | [+0.5, +3.2] | 0.407 | S1: +3.2%, S2: +0.5% |
| p50_ms | mtls1.3-x25519 | plaintext | 4 | +43.9% | [+42.4, +45.3] | [+43.9, +43.9] | 2.5e-06 | S1: +43.9%, S2: +43.9% |
| p99_ms | mtls1.3-x25519 | plaintext | 4 | +63.7% | [+51.9, +75.5] | [+57.5, +69.8] | 0.000429 | S1: +69.8%, S2: +57.5% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 4 | +113.9% | [+111.0, +116.9] | [+113.4, +114.4] | 1.21e-06 | S1: +113.4%, S2: +114.4% |
| window_rps | mtls1.3-x25519-full | plaintext | 4 | +2.0% | [-1.6, +5.6] | [+1.5, +2.5] | 0.177 | S1: +1.5%, S2: +2.5% |
| p50_ms | mtls1.3-x25519-full | plaintext | 4 | +99.7% | [+97.2, +102.2] | [+99.2, +100.2] | 1.11e-06 | S1: +99.2%, S2: +100.2% |
| p99_ms | mtls1.3-x25519-full | plaintext | 4 | +115.5% | [+93.1, +137.8] | [+112.6, +118.3] | 0.000489 | S1: +118.3%, S2: +112.6% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +36.9% | [+35.0, +38.7] | [+35.9, +37.8] | 8.82e-06 | S1: +35.9%, S2: +37.8% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +0.2% | [-4.5, +5.0] | [-1.6, +2.1] | 0.888 | S1: -1.6%, S2: +2.1% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +38.8% | [+38.1, +39.5] | [+38.4, +39.2] | 4.2e-07 | S1: +38.4%, S2: +39.2% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +31.7% | [+19.9, +43.5] | [+28.5, +34.9] | 0.00339 | S1: +28.5%, S2: +34.9% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +3.6% | [+2.1, +5.1] | [+3.6, +3.7] | 0.00445 | S1: +3.7%, S2: +3.6% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -1.8% | [-5.4, +1.7] | [-2.3, -1.4] | 0.198 | S1: -1.4%, S2: -2.3% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +4.2% | [+3.6, +4.8] | [+4.1, +4.3] | 0.000162 | S1: +4.3%, S2: +4.1% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +0.6% | [-13.6, +14.8] | [-0.9, +2.1] | 0.901 | S1: +2.1%, S2: -0.9% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +6.1% | [+1.7, +10.4] | [+4.5, +7.7] | 0.0211 | S1: +4.5%, S2: +7.7% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -0.1% | [-0.4, +0.2] | [-0.1, -0.0] | 0.353 | S1: -0.0%, S2: -0.1% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +5.9% | [+4.0, +7.8] | [+5.4, +6.4] | 0.00227 | S1: +5.4%, S2: +6.4% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +12.3% | [+3.0, +21.5] | [+9.3, +15.2] | 0.0246 | S1: +9.3%, S2: +15.2% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +33.8% | [+28.4, +39.1] | [+32.7, +34.9] | 0.000272 | S1: +34.9%, S2: +32.7% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -1.5% | [-7.8, +4.8] | [-3.0, -0.0] | 0.502 | S1: -3.0%, S2: -0.0% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +36.6% | [+33.9, +39.3] | [+36.2, +37.0] | 2.78e-05 | S1: +37.0%, S2: +36.2% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +17.7% | [+11.2, +24.2] | [+16.1, +19.3] | 0.00324 | S1: +19.3%, S2: +16.1% |

## Point: rate=100/s, mrpc=2

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 4139.1 | 34.5 | [4084.3, 4194.0] |
| mtls1.3-postquantum-full | 4 | 5193.6 | 25.9 | [5152.5, 5234.8] |
| mtls1.3-x25519 | 4 | 3977.9 | 41.8 | [3911.4, 4044.5] |
| mtls1.3-x25519-full | 4 | 5023.3 | 40.0 | [4959.6, 5087.0] |
| plaintext | 4 | 2873.9 | 30.3 | [2825.6, 2922.1] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 106.2 | 1.8 | [103.3, 109.0] |
| mtls1.3-postquantum-full | 4 | 105.4 | 2.4 | [101.7, 109.2] |
| mtls1.3-x25519 | 4 | 105.5 | 2.6 | [101.4, 109.5] |
| mtls1.3-x25519-full | 4 | 105.5 | 2.8 | [101.0, 110.1] |
| plaintext | 4 | 103.5 | 0.8 | [102.2, 104.9] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 4.7 | 0.0 | [4.6, 4.8] |
| mtls1.3-postquantum-full | 4 | 6.6 | 0.1 | [6.5, 6.7] |
| mtls1.3-x25519 | 4 | 4.4 | 0.0 | [4.4, 4.5] |
| mtls1.3-x25519-full | 4 | 6.3 | 0.1 | [6.2, 6.4] |
| plaintext | 4 | 3.2 | 0.0 | [3.2, 3.2] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 12.6 | 0.9 | [11.3, 14.0] |
| mtls1.3-postquantum-full | 4 | 15.5 | 0.3 | [14.9, 16.0] |
| mtls1.3-x25519 | 4 | 12.0 | 0.2 | [11.6, 12.4] |
| mtls1.3-x25519-full | 4 | 14.8 | 0.4 | [14.2, 15.4] |
| plaintext | 4 | 8.7 | 0.3 | [8.2, 9.1] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 4 | +38.4% | [+37.1, +39.8] | [+38.1, +38.7] | 3.07e-06 | S1: +38.1%, S2: +38.7% |
| window_rps | mtls1.3-x25519 | plaintext | 4 | +1.8% | [-1.5, +5.2] | [+1.5, +2.2] | 0.179 | S1: +1.5%, S2: +2.2% |
| p50_ms | mtls1.3-x25519 | plaintext | 4 | +38.4% | [+37.6, +39.3] | [+38.1, +38.8] | 8.44e-07 | S1: +38.1%, S2: +38.8% |
| p99_ms | mtls1.3-x25519 | plaintext | 4 | +38.7% | [+30.2, +47.2] | [+36.1, +41.3] | 0.000708 | S1: +41.3%, S2: +36.1% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 4 | +74.8% | [+71.2, +78.4] | [+73.1, +76.5] | 7.7e-06 | S1: +73.1%, S2: +76.5% |
| window_rps | mtls1.3-x25519-full | plaintext | 4 | +1.9% | [-1.7, +5.5] | [+1.6, +2.2] | 0.192 | S1: +1.6%, S2: +2.2% |
| p50_ms | mtls1.3-x25519-full | plaintext | 4 | +97.3% | [+96.6, +97.9] | [+97.0, +97.5] | 1.91e-08 | S1: +97.0%, S2: +97.5% |
| p99_ms | mtls1.3-x25519-full | plaintext | 4 | +70.4% | [+61.9, +78.8] | [+67.1, +73.7] | 0.000118 | S1: +67.1%, S2: +73.7% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +26.3% | [+24.5, +28.0] | [+25.3, +27.2] | 2.03e-05 | S1: +25.3%, S2: +27.2% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +0.1% | [-3.6, +3.8] | [+0.1, +0.1] | 0.945 | S1: +0.1%, S2: +0.1% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +42.5% | [+41.7, +43.3] | [+42.3, +42.7] | 4.99e-07 | S1: +42.7%, S2: +42.3% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +23.0% | [+14.0, +31.9] | [+18.3, +27.7] | 0.0038 | S1: +18.3%, S2: +27.7% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +3.4% | [+2.1, +4.7] | [+3.3, +3.4] | 0.00348 | S1: +3.4%, S2: +3.3% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -0.0% | [-5.4, +5.3] | [-0.1, +0.0] | 0.991 | S1: +0.0%, S2: -0.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +4.4% | [+4.1, +4.7] | [+4.3, +4.5] | 1.9e-05 | S1: +4.3%, S2: +4.5% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +4.5% | [+1.6, +7.4] | [+4.3, +4.7] | 0.0159 | S1: +4.7%, S2: +4.3% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +4.1% | [+2.1, +6.0] | [+3.1, +5.0] | 0.00732 | S1: +3.1%, S2: +5.0% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +0.7% | [-5.4, +6.8] | [+0.0, +1.5] | 0.729 | S1: +1.5%, S2: +0.0% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +5.9% | [+5.2, +6.7] | [+5.8, +6.1] | 0.000153 | S1: +6.1%, S2: +5.8% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +4.9% | [-8.8, +18.5] | [-1.1, +10.8] | 0.341 | S1: -1.1%, S2: +10.8% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +25.5% | [+23.1, +27.9] | [+25.3, +25.7] | 5.51e-05 | S1: +25.7%, S2: +25.3% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -0.7% | [-2.8, +1.5] | [-1.3, +0.0] | 0.399 | S1: -1.3%, S2: +0.0% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +40.4% | [+39.9, +40.8] | [+40.2, +40.5] | 8.1e-08 | S1: +40.2%, S2: +40.5% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +22.9% | [+11.8, +34.0] | [+20.6, +25.3] | 0.00712 | S1: +25.3%, S2: +20.6% |

## Point: rate=100/s, mrpc=5

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 3511.1 | 954.0 | [1993.2, 5029.1] |
| mtls1.3-postquantum-full | 4 | 3482.6 | 10.0 | [3466.7, 3498.6] |
| mtls1.3-x25519 | 4 | 2975.3 | 25.9 | [2934.1, 3016.6] |
| mtls1.3-x25519-full | 4 | 3396.1 | 17.7 | [3367.9, 3424.3] |
| plaintext | 4 | 2424.0 | 20.9 | [2390.8, 2457.3] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 105.0 | 1.0 | [103.3, 106.6] |
| mtls1.3-postquantum-full | 4 | 106.1 | 2.4 | [102.2, 110.0] |
| mtls1.3-x25519 | 4 | 105.4 | 2.6 | [101.4, 109.5] |
| mtls1.3-x25519-full | 4 | 104.8 | 2.9 | [100.1, 109.5] |
| plaintext | 4 | 106.6 | 2.9 | [102.1, 111.2] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 3.6 | 1.1 | [2.0, 5.3] |
| mtls1.3-postquantum-full | 4 | 3.1 | 0.0 | [3.1, 3.2] |
| mtls1.3-x25519 | 4 | 3.1 | 0.0 | [3.1, 3.2] |
| mtls1.3-x25519-full | 4 | 3.1 | 0.1 | [3.0, 3.2] |
| plaintext | 4 | 2.9 | 0.1 | [2.8, 3.0] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 11.2 | 1.5 | [8.7, 13.6] |
| mtls1.3-postquantum-full | 4 | 14.2 | 0.3 | [13.7, 14.6] |
| mtls1.3-x25519 | 4 | 10.1 | 0.3 | [9.6, 10.5] |
| mtls1.3-x25519-full | 4 | 13.3 | 0.3 | [12.8, 13.8] |
| plaintext | 4 | 8.0 | 0.1 | [7.8, 8.1] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 4 | +22.8% | [+19.8, +25.7] | [+21.5, +24.0] | 0.000145 | S1: +24.0%, S2: +21.5% |
| window_rps | mtls1.3-x25519 | plaintext | 4 | -1.1% | [-4.5, +2.4] | [-2.2, +0.0] | 0.391 | S1: +0.0%, S2: -2.2% |
| p50_ms | mtls1.3-x25519 | plaintext | 4 | +6.5% | [+3.7, +9.2] | [+5.4, +7.5] | 0.00479 | S1: +7.5%, S2: +5.4% |
| p99_ms | mtls1.3-x25519 | plaintext | 4 | +26.1% | [+22.8, +29.4] | [+25.3, +27.0] | 0.000139 | S1: +27.0%, S2: +25.3% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 4 | +40.1% | [+39.0, +41.2] | [+39.8, +40.4] | 1.53e-06 | S1: +40.4%, S2: +39.8% |
| window_rps | mtls1.3-x25519-full | plaintext | 4 | -1.7% | [-5.2, +1.8] | [-2.0, -1.4] | 0.217 | S1: -1.4%, S2: -2.0% |
| p50_ms | mtls1.3-x25519-full | plaintext | 4 | +6.1% | [+5.0, +7.2] | [+5.9, +6.3] | 0.000432 | S1: +5.9%, S2: +6.3% |
| p99_ms | mtls1.3-x25519-full | plaintext | 4 | +66.7% | [+63.0, +70.5] | [+65.3, +68.2] | 1.24e-05 | S1: +65.3%, S2: +68.2% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +14.1% | [+12.1, +16.2] | [+13.3, +15.0] | 0.000202 | S1: +13.3%, S2: +15.0% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -0.6% | [-6.8, +5.7] | [-1.4, +0.3] | 0.793 | S1: -1.4%, S2: +0.3% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -0.3% | [-2.7, +2.1] | [-1.6, +0.9] | 0.693 | S1: -1.6%, S2: +0.9% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +32.2% | [+28.4, +36.1] | [+30.2, +34.3] | 0.000116 | S1: +30.2%, S2: +34.3% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +2.5% | [+1.9, +3.2] | [+2.3, +2.8] | 0.00126 | S1: +2.8%, S2: +2.3% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +1.3% | [-3.2, +5.8] | [+1.2, +1.4] | 0.431 | S1: +1.4%, S2: +1.2% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -0.2% | [-2.2, +1.8] | [-1.1, +0.8] | 0.814 | S1: +0.8%, S2: -1.1% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +6.7% | [+1.7, +11.8] | [+5.6, +7.8] | 0.0242 | S1: +5.6%, S2: +7.8% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +18.1% | [-33.8, +70.0] | [+1.6, +34.6] | 0.348 | S1: +1.6%, S2: +34.6% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -0.4% | [-5.0, +4.2] | [-2.2, +1.4] | 0.801 | S1: +1.4%, S2: -2.2% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +16.6% | [-36.2, +69.3] | [-0.2, +33.3] | 0.392 | S1: -0.2%, S2: +33.3% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +11.3% | [-16.0, +38.7] | [+1.9, +20.8] | 0.279 | S1: +1.9%, S2: +20.8% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +3.7% | [-31.3, +38.6] | [-7.4, +14.7] | 0.761 | S1: +14.7%, S2: -7.4% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +1.1% | [-4.1, +6.3] | [-1.4, +3.6] | 0.55 | S1: -1.4%, S2: +3.6% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -10.4% | [-41.7, +20.8] | [-20.3, -0.6] | 0.365 | S1: -0.6%, S2: -20.3% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +28.5% | [+4.4, +52.6] | [+21.9, +35.0] | 0.0329 | S1: +35.0%, S2: +21.9% |

## Point: rate=200/s, mrpc=0

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 1987.5 | 168.8 | [1719.0, 2256.0] |
| mtls1.3-postquantum-full | 4 | 1902.0 | 170.9 | [1630.0, 2174.0] |
| mtls1.3-x25519 | 4 | 2070.1 | 25.2 | [2030.0, 2110.2] |
| mtls1.3-x25519-full | 4 | 2056.7 | 13.6 | [2035.1, 2078.3] |
| plaintext | 4 | 1848.4 | 147.4 | [1613.8, 2083.0] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 209.8 | 2.5 | [205.8, 213.7] |
| mtls1.3-postquantum-full | 4 | 214.4 | 4.4 | [207.4, 221.3] |
| mtls1.3-x25519 | 4 | 214.1 | 4.4 | [207.1, 221.0] |
| mtls1.3-x25519-full | 4 | 208.2 | 7.3 | [196.6, 219.8] |
| plaintext | 4 | 210.1 | 5.1 | [202.1, 218.2] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 2.6 | 0.0 | [2.5, 2.6] |
| mtls1.3-postquantum-full | 4 | 2.5 | 0.1 | [2.4, 2.7] |
| mtls1.3-x25519 | 4 | 2.6 | 0.0 | [2.5, 2.7] |
| mtls1.3-x25519-full | 4 | 2.6 | 0.0 | [2.5, 2.7] |
| plaintext | 4 | 2.5 | 0.1 | [2.4, 2.6] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 6.8 | 2.1 | [3.4, 10.2] |
| mtls1.3-postquantum-full | 4 | 5.7 | 2.4 | [2.0, 9.5] |
| mtls1.3-x25519 | 4 | 7.8 | 0.3 | [7.3, 8.2] |
| mtls1.3-x25519-full | 4 | 7.8 | 0.2 | [7.5, 8.1] |
| plaintext | 4 | 6.4 | 2.0 | [3.3, 9.6] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 4 | +12.5% | [-1.1, +26.1] | [+8.2, +16.8] | 0.0612 | S1: +8.2%, S2: +16.8% |
| window_rps | mtls1.3-x25519 | plaintext | 4 | +1.9% | [-1.9, +5.7] | [+1.7, +2.1] | 0.21 | S1: +1.7%, S2: +2.1% |
| p50_ms | mtls1.3-x25519 | plaintext | 4 | +4.0% | [+1.7, +6.3] | [+3.3, +4.7] | 0.0115 | S1: +3.3%, S2: +4.7% |
| p99_ms | mtls1.3-x25519 | plaintext | 4 | +32.7% | [-51.8, +117.1] | [+9.1, +56.2] | 0.306 | S1: +9.1%, S2: +56.2% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 4 | +11.8% | [-2.5, +26.2] | [+7.4, +16.3] | 0.079 | S1: +7.4%, S2: +16.3% |
| window_rps | mtls1.3-x25519-full | plaintext | 4 | -0.9% | [-7.4, +5.6] | [-1.9, +0.2] | 0.696 | S1: -1.9%, S2: +0.2% |
| p50_ms | mtls1.3-x25519-full | plaintext | 4 | +3.9% | [+1.3, +6.5] | [+3.3, +4.5] | 0.0179 | S1: +3.3%, S2: +4.5% |
| p99_ms | mtls1.3-x25519-full | plaintext | 4 | +33.1% | [-52.8, +118.9] | [+7.8, +58.3] | 0.308 | S1: +7.8%, S2: +58.3% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -0.6% | [-1.5, +0.2] | [-0.8, -0.5] | 0.104 | S1: -0.8%, S2: -0.5% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -2.7% | [-5.8, +0.3] | [-3.6, -1.9] | 0.0642 | S1: -3.6%, S2: -1.9% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -0.1% | [-0.7, +0.5] | [-0.2, +0.1] | 0.735 | S1: +0.1%, S2: -0.2% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +0.2% | [-2.7, +3.1] | [-1.2, +1.6] | 0.841 | S1: -1.2%, S2: +1.6% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -7.5% | [-20.7, +5.6] | [-7.6, -7.4] | 0.166 | S1: -7.6%, S2: -7.4% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +3.0% | [-0.2, +6.2] | [+2.2, +3.8] | 0.0588 | S1: +3.8%, S2: +2.2% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -2.1% | [-5.8, +1.5] | [-2.3, -2.0] | 0.16 | S1: -2.3%, S2: -2.0% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -26.6% | [-74.1, +20.9] | [-28.2, -25.1] | 0.173 | S1: -28.2%, S2: -25.1% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -4.0% | [-15.6, +7.5] | [-8.1, -0.0] | 0.348 | S1: -0.0%, S2: -8.1% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -2.0% | [-5.8, +1.9] | [-4.1, +0.1] | 0.201 | S1: +0.1%, S2: -4.1% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -1.2% | [-4.0, +1.5] | [-2.4, -0.0] | 0.253 | S1: -0.0%, S2: -2.4% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -12.5% | [-53.5, +28.5] | [-25.2, +0.2] | 0.403 | S1: +0.2%, S2: -25.2% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -4.0% | [-16.9, +8.8] | [-8.3, +0.2] | 0.39 | S1: -8.3%, S2: +0.2% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +2.2% | [-1.9, +6.3] | [+0.0, +4.4] | 0.182 | S1: +0.0%, S2: +4.4% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -1.0% | [-4.8, +2.8] | [-2.2, +0.2] | 0.466 | S1: -2.2%, S2: +0.2% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -13.5% | [-58.1, +31.2] | [-29.5, +2.6] | 0.408 | S1: -29.5%, S2: +2.6% |

## Point: rate=200/s, mrpc=1

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 5163.1 | 486.7 | [4388.7, 5937.5] |
| mtls1.3-postquantum-full | 4 | 6949.5 | 457.3 | [6221.8, 7677.1] |
| mtls1.3-x25519 | 4 | 4822.4 | 442.0 | [4119.2, 5525.7] |
| mtls1.3-x25519-full | 4 | 6672.0 | 402.8 | [6031.0, 7313.0] |
| plaintext | 4 | 3006.7 | 255.5 | [2600.2, 3413.2] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 213.6 | 5.7 | [204.6, 222.7] |
| mtls1.3-postquantum-full | 4 | 211.4 | 7.5 | [199.4, 223.3] |
| mtls1.3-x25519 | 4 | 210.7 | 6.1 | [201.0, 220.4] |
| mtls1.3-x25519-full | 4 | 207.8 | 1.1 | [206.0, 209.5] |
| plaintext | 4 | 209.0 | 6.2 | [199.2, 218.9] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 5.2 | 0.2 | [4.9, 5.5] |
| mtls1.3-postquantum-full | 4 | 7.7 | 0.3 | [7.3, 8.1] |
| mtls1.3-x25519 | 4 | 4.8 | 0.2 | [4.6, 5.1] |
| mtls1.3-x25519-full | 4 | 7.3 | 0.2 | [7.0, 7.6] |
| plaintext | 4 | 3.4 | 0.1 | [3.2, 3.5] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 20.1 | 10.8 | [2.8, 37.3] |
| mtls1.3-postquantum-full | 4 | 19.6 | 16.1 | [-6.1, 45.3] |
| mtls1.3-x25519 | 4 | 13.6 | 9.8 | [-2.1, 29.2] |
| mtls1.3-x25519-full | 4 | 18.1 | 11.5 | [-0.2, 36.5] |
| plaintext | 4 | 6.1 | 3.2 | [1.0, 11.2] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 4 | +60.3% | [+58.3, +62.3] | [+60.2, +60.4] | 2.54e-06 | S1: +60.2%, S2: +60.4% |
| window_rps | mtls1.3-x25519 | plaintext | 4 | +0.9% | [-5.3, +7.0] | [-0.0, +1.7] | 0.682 | S1: +1.7%, S2: -0.0% |
| p50_ms | mtls1.3-x25519 | plaintext | 4 | +44.6% | [+43.3, +45.8] | [+44.4, +44.7] | 1.54e-06 | S1: +44.7%, S2: +44.4% |
| p99_ms | mtls1.3-x25519 | plaintext | 4 | +109.2% | [+45.0, +173.5] | [+103.3, +115.1] | 0.0124 | S1: +115.1%, S2: +103.3% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 4 | +122.2% | [+114.1, +130.3] | [+119.7, +124.7] | 1.98e-05 | S1: +119.7%, S2: +124.7% |
| window_rps | mtls1.3-x25519-full | plaintext | 4 | -0.6% | [-4.6, +3.5] | [-2.1, +1.0] | 0.694 | S1: +1.0%, S2: -2.1% |
| p50_ms | mtls1.3-x25519-full | plaintext | 4 | +119.0% | [+117.7, +120.3] | [+118.9, +119.1] | 9.09e-08 | S1: +119.1%, S2: +118.9% |
| p99_ms | mtls1.3-x25519-full | plaintext | 4 | +188.6% | [+88.7, +288.4] | [+177.2, +200.0] | 0.00923 | S1: +177.2%, S2: +200.0% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +38.6% | [+32.2, +45.0] | [+37.2, +40.1] | 0.000311 | S1: +37.2%, S2: +40.1% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -1.4% | [-5.8, +3.1] | [-2.0, -0.7] | 0.402 | S1: -0.7%, S2: -2.0% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +51.5% | [+49.5, +53.5] | [+51.4, +51.6] | 4.2e-06 | S1: +51.4%, S2: +51.6% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +38.0% | [+12.9, +63.2] | [+30.2, +45.9] | 0.0171 | S1: +30.2%, S2: +45.9% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +4.1% | [+2.9, +5.4] | [+3.7, +4.6] | 0.00178 | S1: +4.6%, S2: +3.7% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +1.7% | [-3.3, +6.7] | [-0.9, +4.4] | 0.349 | S1: -0.9%, S2: +4.4% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +4.5% | [+2.9, +6.2] | [+4.4, +4.7] | 0.00295 | S1: +4.7%, S2: +4.4% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +3.2% | [-34.0, +40.4] | [-9.8, +16.3] | 0.801 | S1: +16.3%, S2: -9.8% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +7.0% | [+6.3, +7.8] | [+7.0, +7.1] | 7.64e-05 | S1: +7.0%, S2: +7.1% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +1.4% | [-2.0, +4.8] | [+0.5, +2.3] | 0.276 | S1: +0.5%, S2: +2.3% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +7.9% | [+7.1, +8.8] | [+7.9, +7.9] | 7.46e-05 | S1: +7.9%, S2: +7.9% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +70.0% | [-83.1, +223.1] | [+23.7, +116.3] | 0.242 | S1: +116.3%, S2: +23.7% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +34.9% | [+28.8, +40.9] | [+34.0, +35.7] | 0.00036 | S1: +34.0%, S2: +35.7% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -1.1% | [-3.5, +1.4] | [-2.2, +0.0] | 0.259 | S1: -2.2%, S2: +0.0% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +46.7% | [+45.7, +47.7] | [+46.6, +46.9] | 6.24e-07 | S1: +46.9%, S2: +46.6% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -2.4% | [-67.9, +63.2] | [-11.7, +7.0] | 0.916 | S1: -11.7%, S2: +7.0% |

## Point: rate=200/s, mrpc=2

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 3672.1 | 381.7 | [3064.7, 4279.5] |
| mtls1.3-postquantum-full | 4 | 4675.1 | 366.8 | [4091.4, 5258.8] |
| mtls1.3-x25519 | 4 | 3499.6 | 350.7 | [2941.5, 4057.7] |
| mtls1.3-x25519-full | 4 | 4503.3 | 352.7 | [3942.1, 5064.4] |
| plaintext | 4 | 2485.4 | 256.4 | [2077.5, 2893.4] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 207.0 | 1.7 | [204.3, 209.7] |
| mtls1.3-postquantum-full | 4 | 209.8 | 2.3 | [206.1, 213.4] |
| mtls1.3-x25519 | 4 | 212.6 | 5.8 | [203.3, 221.8] |
| mtls1.3-x25519-full | 4 | 213.2 | 6.2 | [203.4, 223.1] |
| plaintext | 4 | 209.1 | 6.0 | [199.6, 218.6] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 4.3 | 0.1 | [4.2, 4.5] |
| mtls1.3-postquantum-full | 4 | 5.3 | 0.4 | [4.7, 5.8] |
| mtls1.3-x25519 | 4 | 4.1 | 0.1 | [3.9, 4.3] |
| mtls1.3-x25519-full | 4 | 5.0 | 0.4 | [4.4, 5.6] |
| plaintext | 4 | 3.0 | 0.1 | [2.9, 3.1] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 12.7 | 6.8 | [1.9, 23.5] |
| mtls1.3-postquantum-full | 4 | 16.9 | 8.1 | [4.1, 29.7] |
| mtls1.3-x25519 | 4 | 11.6 | 6.3 | [1.6, 21.6] |
| mtls1.3-x25519-full | 4 | 15.9 | 7.8 | [3.5, 28.4] |
| plaintext | 4 | 7.0 | 3.4 | [1.6, 12.4] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 4 | +40.8% | [+38.9, +42.7] | [+40.5, +41.2] | 6.92e-06 | S1: +40.5%, S2: +41.2% |
| window_rps | mtls1.3-x25519 | plaintext | 4 | +1.7% | [-1.8, +5.2] | [+1.2, +2.2] | 0.218 | S1: +1.2%, S2: +2.2% |
| p50_ms | mtls1.3-x25519 | plaintext | 4 | +38.2% | [+36.4, +40.0] | [+37.4, +39.0] | 6.89e-06 | S1: +39.0%, S2: +37.4% |
| p99_ms | mtls1.3-x25519 | plaintext | 4 | +60.5% | [+38.2, +82.8] | [+50.9, +70.1] | 0.00327 | S1: +70.1%, S2: +50.9% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 4 | +81.5% | [+74.3, +88.8] | [+77.6, +85.5] | 4.83e-05 | S1: +77.6%, S2: +85.5% |
| window_rps | mtls1.3-x25519-full | plaintext | 4 | +2.0% | [-1.7, +5.7] | [+1.8, +2.2] | 0.18 | S1: +1.8%, S2: +2.2% |
| p50_ms | mtls1.3-x25519-full | plaintext | 4 | +69.0% | [+54.4, +83.7] | [+61.1, +77.0] | 0.000648 | S1: +77.0%, S2: +61.1% |
| p99_ms | mtls1.3-x25519-full | plaintext | 4 | +126.8% | [+99.9, +153.7] | [+126.0, +127.7] | 0.000642 | S1: +126.0%, S2: +127.7% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +28.9% | [+24.1, +33.7] | [+26.5, +31.3] | 0.000306 | S1: +26.5%, S2: +31.3% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +0.3% | [-3.3, +3.9] | [+0.0, +0.6] | 0.796 | S1: +0.6%, S2: +0.0% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +22.3% | [+13.0, +31.5] | [+17.3, +27.3] | 0.00462 | S1: +27.3%, S2: +17.3% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +41.8% | [+23.4, +60.2] | [+32.6, +51.0] | 0.00549 | S1: +32.6%, S2: +51.0% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +3.8% | [+2.8, +4.9] | [+3.8, +3.8] | 0.00135 | S1: +3.8%, S2: +3.8% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -1.6% | [-6.5, +3.4] | [-4.1, +1.0] | 0.387 | S1: +1.0%, S2: -4.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +5.5% | [+4.4, +6.6] | [+5.2, +5.8] | 0.000477 | S1: +5.2%, S2: +5.8% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +6.5% | [-2.1, +15.1] | [+6.4, +6.6] | 0.0955 | S1: +6.4%, S2: +6.6% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +4.9% | [+3.9, +5.9] | [+4.6, +5.2] | 0.000524 | S1: +5.2%, S2: +4.6% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -2.6% | [-5.9, +0.8] | [-4.2, -0.9] | 0.0907 | S1: -0.9%, S2: -4.2% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +5.9% | [+5.6, +6.2] | [+5.8, +6.0] | 1.06e-05 | S1: +6.0%, S2: +5.8% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +9.6% | [+0.9, +18.4] | [+9.6, +9.7] | 0.0394 | S1: +9.6%, S2: +9.7% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +27.6% | [+22.3, +32.8] | [+24.7, +30.4] | 0.000468 | S1: +24.7%, S2: +30.4% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +1.3% | [-1.1, +3.7] | [+0.1, +2.5] | 0.178 | S1: +2.5%, S2: +0.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +21.8% | [+13.4, +30.3] | [+17.3, +26.4] | 0.00377 | S1: +26.4%, S2: +17.3% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +37.7% | [+20.1, +55.3] | [+28.8, +46.6] | 0.00643 | S1: +28.8%, S2: +46.6% |

## Point: rate=200/s, mrpc=5

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 2539.1 | 247.0 | [2146.1, 2932.2] |
| mtls1.3-postquantum-full | 4 | 3065.4 | 277.6 | [2623.7, 3507.1] |
| mtls1.3-x25519 | 4 | 2643.0 | 217.5 | [2296.9, 2989.0] |
| mtls1.3-x25519-full | 4 | 3007.5 | 259.7 | [2594.3, 3420.7] |
| plaintext | 4 | 2160.4 | 177.0 | [1878.7, 2442.1] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 210.1 | 5.1 | [201.9, 218.3] |
| mtls1.3-postquantum-full | 4 | 212.9 | 6.4 | [202.8, 223.1] |
| mtls1.3-x25519 | 4 | 210.6 | 5.8 | [201.4, 219.8] |
| mtls1.3-x25519-full | 4 | 210.0 | 5.0 | [202.1, 218.0] |
| plaintext | 4 | 211.8 | 4.5 | [204.7, 218.9] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 2.8 | 0.1 | [2.6, 2.9] |
| mtls1.3-postquantum-full | 4 | 2.9 | 0.1 | [2.7, 3.1] |
| mtls1.3-x25519 | 4 | 2.9 | 0.1 | [2.7, 3.1] |
| mtls1.3-x25519-full | 4 | 2.9 | 0.1 | [2.7, 3.1] |
| plaintext | 4 | 2.7 | 0.1 | [2.6, 2.9] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 8.5 | 5.0 | [0.6, 16.4] |
| mtls1.3-postquantum-full | 4 | 13.7 | 5.6 | [4.8, 22.5] |
| mtls1.3-x25519 | 4 | 10.3 | 3.4 | [4.9, 15.7] |
| mtls1.3-x25519-full | 4 | 12.0 | 4.2 | [5.4, 18.6] |
| plaintext | 4 | 7.5 | 2.1 | [4.1, 10.8] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 4 | +22.4% | [+14.3, +30.5] | [+19.9, +24.9] | 0.00307 | S1: +24.9%, S2: +19.9% |
| window_rps | mtls1.3-x25519 | plaintext | 4 | -0.5% | [-6.5, +5.4] | [-1.0, -0.0] | 0.792 | S1: -1.0%, S2: -0.0% |
| p50_ms | mtls1.3-x25519 | plaintext | 4 | +4.9% | [+2.4, +7.4] | [+4.8, +5.0] | 0.00852 | S1: +5.0%, S2: +4.8% |
| p99_ms | mtls1.3-x25519 | plaintext | 4 | +37.2% | [+4.6, +69.7] | [+32.7, +41.6] | 0.0358 | S1: +41.6%, S2: +32.7% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 4 | +39.5% | [+23.3, +55.7] | [+34.2, +44.8] | 0.00444 | S1: +44.8%, S2: +34.2% |
| window_rps | mtls1.3-x25519-full | plaintext | 4 | -0.8% | [-3.0, +1.4] | [-1.5, -0.1] | 0.316 | S1: -1.5%, S2: -0.1% |
| p50_ms | mtls1.3-x25519-full | plaintext | 4 | +5.9% | [+2.6, +9.2] | [+5.3, +6.5] | 0.011 | S1: +6.5%, S2: +5.3% |
| p99_ms | mtls1.3-x25519-full | plaintext | 4 | +63.7% | [-1.1, +128.4] | [+48.9, +78.4] | 0.0522 | S1: +78.4%, S2: +48.9% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +13.8% | [+7.6, +20.0] | [+11.8, +15.9] | 0.00569 | S1: +15.9%, S2: +11.8% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -0.2% | [-6.7, +6.3] | [-0.5, +0.1] | 0.932 | S1: -0.5%, S2: +0.1% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +0.9% | [-0.3, +2.2] | [+0.5, +1.4] | 0.0909 | S1: +1.4%, S2: +0.5% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +18.1% | [-10.8, +47.1] | [+9.6, +26.7] | 0.14 | S1: +26.7%, S2: +9.6% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +1.9% | [+0.6, +3.2] | [+1.4, +2.4] | 0.0182 | S1: +2.4%, S2: +1.4% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +1.4% | [-3.3, +6.1] | [+0.6, +2.2] | 0.414 | S1: +0.6%, S2: +2.2% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -0.4% | [-2.3, +1.5] | [-0.9, +0.0] | 0.55 | S1: +0.0%, S2: -0.9% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +12.1% | [-4.3, +28.5] | [+6.8, +17.3] | 0.1 | S1: +17.3%, S2: +6.8% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -3.7% | [-16.7, +9.3] | [-10.1, +2.6] | 0.428 | S1: +2.6%, S2: -10.1% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -0.2% | [-3.7, +3.3] | [-0.5, +0.1] | 0.865 | S1: -0.5%, S2: +0.1% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -3.0% | [-8.3, +2.3] | [-5.7, -0.3] | 0.17 | S1: -0.3%, S2: -5.7% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -16.0% | [-71.0, +39.1] | [-44.3, +12.4] | 0.425 | S1: +12.4%, S2: -44.3% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +21.1% | [+4.5, +37.6] | [+15.6, +26.6] | 0.0271 | S1: +15.6%, S2: +26.6% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +1.4% | [-3.5, +6.2] | [+0.6, +2.1] | 0.437 | S1: +0.6%, S2: +2.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +3.7% | [-1.7, +9.1] | [+1.7, +5.7] | 0.116 | S1: +1.7%, S2: +5.7% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +76.8% | [-45.2, +198.8] | [+32.8, +120.9] | 0.139 | S1: +32.8%, S2: +120.9% |

## Point: rate=300/s, mrpc=0

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 1989.8 | 10.2 | [1973.5, 2006.1] |
| mtls1.3-postquantum-full | 4 | 1990.6 | 12.2 | [1971.1, 2010.0] |
| mtls1.3-x25519 | 4 | 2012.5 | 15.1 | [1988.5, 2036.5] |
| mtls1.3-x25519-full | 4 | 2000.9 | 2.9 | [1996.2, 2005.5] |
| plaintext | 3 | 1852.3 | 3.2 | [1844.4, 1860.1] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 317.1 | 9.3 | [302.2, 332.0] |
| mtls1.3-postquantum-full | 4 | 316.8 | 9.1 | [302.3, 331.2] |
| mtls1.3-x25519 | 4 | 317.9 | 6.7 | [307.2, 328.6] |
| mtls1.3-x25519-full | 4 | 313.4 | 5.9 | [303.9, 322.8] |
| plaintext | 3 | 320.3 | 4.5 | [309.2, 331.5] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 2.5 | 0.0 | [2.5, 2.6] |
| mtls1.3-postquantum-full | 4 | 2.5 | 0.0 | [2.4, 2.6] |
| mtls1.3-x25519 | 4 | 2.5 | 0.1 | [2.4, 2.7] |
| mtls1.3-x25519-full | 4 | 2.5 | 0.0 | [2.5, 2.6] |
| plaintext | 3 | 2.4 | 0.0 | [2.4, 2.5] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 8.4 | 0.1 | [8.2, 8.6] |
| mtls1.3-postquantum-full | 4 | 8.4 | 0.2 | [8.1, 8.7] |
| mtls1.3-x25519 | 4 | 9.2 | 1.1 | [7.5, 10.9] |
| mtls1.3-x25519-full | 4 | 8.4 | 0.5 | [7.6, 9.2] |
| plaintext | 3 | 7.7 | 0.5 | [6.6, 8.9] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 3 | +8.4% | [+6.4, +10.3] | [+7.9, +9.2] | 0.00301 | S1: +7.9%, S2: +9.2% |
| window_rps | mtls1.3-x25519 | plaintext | 3 | -1.2% | [-5.8, +3.3] | [-1.8, +0.0] | 0.366 | S1: -1.8%, S2: +0.0% |
| p50_ms | mtls1.3-x25519 | plaintext | 3 | +2.7% | [+1.4, +4.0] | [+2.4, +3.3] | 0.0128 | S1: +2.4%, S2: +3.3% |
| p99_ms | mtls1.3-x25519 | plaintext | 3 | +12.4% | [-3.2, +28.1] | [+11.1, +13.1] | 0.076 | S1: +13.1%, S2: +11.1% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 3 | +8.0% | [+7.2, +8.9] | [+7.9, +8.3] | 0.000583 | S1: +7.9%, S2: +8.3% |
| window_rps | mtls1.3-x25519-full | plaintext | 3 | -2.3% | [-7.5, +2.9] | [-4.1, -1.4] | 0.197 | S1: -1.4%, S2: -4.1% |
| p50_ms | mtls1.3-x25519-full | plaintext | 3 | +2.8% | [+2.0, +3.7] | [+2.7, +3.2] | 0.00499 | S1: +2.7%, S2: +3.2% |
| p99_ms | mtls1.3-x25519-full | plaintext | 3 | +7.6% | [-21.9, +37.1] | [+2.7, +17.4] | 0.382 | S1: +2.7%, S2: +17.4% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -0.6% | [-1.6, +0.5] | [-1.1, -0.0] | 0.186 | S1: -0.0%, S2: -1.1% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -1.4% | [-6.7, +3.9] | [-3.3, +0.5] | 0.464 | S1: +0.5%, S2: -3.3% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -0.7% | [-3.2, +1.8] | [-1.6, +0.3] | 0.463 | S1: +0.3%, S2: -1.6% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -7.5% | [-22.9, +7.9] | [-9.3, -5.6] | 0.22 | S1: -9.3%, S2: -5.6% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -0.5% | [-1.3, +0.3] | [-0.7, -0.3] | 0.126 | S1: -0.7%, S2: -0.3% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +1.1% | [-2.2, +4.4] | [+0.0, +2.1] | 0.379 | S1: +0.0%, S2: +2.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -0.1% | [-0.8, +0.6] | [-0.3, +0.1] | 0.7 | S1: -0.3%, S2: +0.1% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -0.0% | [-12.5, +12.5] | [-5.2, +5.1] | 0.995 | S1: +5.1%, S2: -5.2% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -1.1% | [-2.4, +0.2] | [-1.6, -0.7] | 0.0698 | S1: -0.7%, S2: -1.6% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -0.2% | [-5.7, +5.3] | [-1.1, +0.6] | 0.903 | S1: +0.6%, S2: -1.1% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -0.8% | [-3.8, +2.2] | [-1.9, +0.3] | 0.464 | S1: +0.3%, S2: -1.9% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -7.6% | [-22.2, +7.0] | [-9.8, -5.4] | 0.195 | S1: -5.4%, S2: -9.8% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +0.0% | [-0.9, +1.0] | [-0.1, +0.2] | 0.908 | S1: -0.1%, S2: +0.2% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -0.1% | [-0.4, +0.2] | [-0.1, -0.1] | 0.375 | S1: -0.1%, S2: -0.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +0.0% | [-0.8, +0.9] | [-0.4, +0.4] | 0.899 | S1: -0.4%, S2: +0.4% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -0.1% | [-3.0, +2.9] | [-0.8, +0.6] | 0.95 | S1: +0.6%, S2: -0.8% |

## Point: rate=300/s, mrpc=1

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 6459.7 | 22.5 | [6423.8, 6495.5] |
| mtls1.3-postquantum-full | 1 | 7909.8 | nan | [nan, nan] |
| mtls1.3-x25519 | 3 | 6286.2 | 69.8 | [6112.7, 6459.6] |
| plaintext | 4 | 4202.1 | 28.9 | [4156.2, 4248.0] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 313.8 | 4.0 | [307.4, 320.2] |
| mtls1.3-postquantum-full | 1 | 304.3 | nan | [nan, nan] |
| mtls1.3-x25519 | 3 | 317.4 | 11.5 | [288.8, 346.0] |
| plaintext | 4 | 320.3 | 4.9 | [312.4, 328.1] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 6.8 | 0.2 | [6.6, 7.1] |
| mtls1.3-postquantum-full | 1 | 11.5 | nan | [nan, nan] |
| mtls1.3-x25519 | 3 | 6.8 | 0.2 | [6.3, 7.3] |
| plaintext | 4 | 3.8 | 0.2 | [3.6, 4.1] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 238.9 | 103.9 | [73.5, 404.3] |
| mtls1.3-postquantum-full | 1 | 488.1 | nan | [nan, nan] |
| mtls1.3-x25519 | 3 | 170.8 | 8.1 | [150.8, 190.8] |
| plaintext | 4 | 124.0 | 40.7 | [59.2, 188.9] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 3 | +49.9% | [+46.4, +53.4] | [+49.3, +51.2] | 0.000266 | S1: +49.3%, S2: +51.2% |
| window_rps | mtls1.3-x25519 | plaintext | 3 | -0.4% | [-6.0, +5.1] | [-1.5, +1.8] | 0.771 | S1: -1.5%, S2: +1.8% |
| p50_ms | mtls1.3-x25519 | plaintext | 3 | +79.0% | [+67.7, +90.3] | [+74.1, +81.4] | 0.00111 | S1: +81.4%, S2: +74.1% |
| p99_ms | mtls1.3-x25519 | plaintext | 3 | +40.4% | [-73.9, +154.8] | [-12.6, +67.0] | 0.268 | S1: +67.0%, S2: -12.6% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 3 | +2.7% | [-0.2, +5.6] | [+1.3, +3.3] | 0.0589 | S1: +3.3%, S2: +1.3% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 3 | -0.7% | [-10.3, +8.8] | [-4.9, +1.4] | 0.772 | S1: +1.4%, S2: -4.9% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 3 | +0.3% | [+0.1, +0.5] | [+0.2, +0.3] | 0.0265 | S1: +0.3%, S2: +0.2% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 3 | +51.8% | [-139.8, +243.4] | [+12.0, +131.3] | 0.365 | S1: +12.0%, S2: +131.3% |

## Point: rate=300/s, mrpc=2

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 4176.3 | 26.3 | [4134.4, 4218.2] |
| mtls1.3-postquantum-full | 4 | 4850.7 | 86.9 | [4712.4, 4988.9] |
| mtls1.3-x25519 | 4 | 3992.9 | 38.0 | [3932.5, 4053.4] |
| mtls1.3-x25519-full | 4 | 4730.0 | 18.5 | [4700.6, 4759.5] |
| plaintext | 4 | 2649.9 | 21.0 | [2616.6, 2683.3] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 317.0 | 5.0 | [309.1, 324.9] |
| mtls1.3-postquantum-full | 4 | 314.5 | 8.0 | [301.8, 327.1] |
| mtls1.3-x25519 | 4 | 319.0 | 8.3 | [305.8, 332.1] |
| mtls1.3-x25519-full | 4 | 324.1 | 4.9 | [316.3, 331.8] |
| plaintext | 4 | 314.3 | 10.0 | [298.4, 330.2] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 4.9 | 0.1 | [4.7, 5.0] |
| mtls1.3-postquantum-full | 4 | 6.2 | 0.2 | [5.9, 6.6] |
| mtls1.3-x25519 | 4 | 4.5 | 0.1 | [4.3, 4.6] |
| mtls1.3-x25519-full | 4 | 6.0 | 0.1 | [5.9, 6.2] |
| plaintext | 4 | 3.0 | 0.1 | [2.9, 3.1] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 33.4 | 6.5 | [23.0, 43.8] |
| mtls1.3-postquantum-full | 4 | 52.1 | 11.2 | [34.3, 70.0] |
| mtls1.3-x25519 | 4 | 31.0 | 1.8 | [28.1, 33.9] |
| mtls1.3-x25519-full | 4 | 51.2 | 11.5 | [32.8, 69.5] |
| plaintext | 4 | 11.5 | 0.8 | [10.2, 12.7] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 4 | +50.7% | [+47.1, +54.3] | [+49.8, +51.5] | 2.47e-05 | S1: +51.5%, S2: +49.8% |
| window_rps | mtls1.3-x25519 | plaintext | 4 | +1.5% | [-1.3, +4.3] | [+0.1, +2.9] | 0.182 | S1: +2.9%, S2: +0.1% |
| p50_ms | mtls1.3-x25519 | plaintext | 4 | +49.5% | [+48.8, +50.2] | [+49.5, +49.6] | 1.99e-07 | S1: +49.6%, S2: +49.5% |
| p99_ms | mtls1.3-x25519 | plaintext | 4 | +171.4% | [+132.3, +210.4] | [+152.4, +190.3] | 0.000797 | S1: +190.3%, S2: +152.4% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 4 | +78.5% | [+75.2, +81.8] | [+78.2, +78.9] | 5.23e-06 | S1: +78.9%, S2: +78.2% |
| window_rps | mtls1.3-x25519-full | plaintext | 4 | +3.2% | [-0.2, +6.6] | [+2.6, +3.8] | 0.0596 | S1: +3.8%, S2: +2.6% |
| p50_ms | mtls1.3-x25519-full | plaintext | 4 | +101.0% | [+97.1, +104.8] | [+100.7, +101.2] | 3.81e-06 | S1: +100.7%, S2: +101.2% |
| p99_ms | mtls1.3-x25519-full | plaintext | 4 | +344.7% | [+212.0, +477.3] | [+307.8, +381.5] | 0.0037 | S1: +307.8%, S2: +381.5% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +18.5% | [+16.8, +20.1] | [+18.0, +18.9] | 4.66e-05 | S1: +18.0%, S2: +18.9% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +1.6% | [-2.1, +5.4] | [+0.8, +2.4] | 0.26 | S1: +0.8%, S2: +2.4% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +34.4% | [+31.7, +37.1] | [+34.2, +34.6] | 3.42e-05 | S1: +34.2%, S2: +34.6% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +65.0% | [+9.5, +120.5] | [+40.5, +89.5] | 0.0337 | S1: +40.5%, S2: +89.5% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +2.6% | [-0.8, +5.9] | [+1.2, +3.9] | 0.0934 | S1: +1.2%, S2: +3.9% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -3.0% | [-5.3, -0.6] | [-3.7, -2.3] | 0.0271 | S1: -3.7%, S2: -2.3% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +3.0% | [-0.9, +7.0] | [+1.9, +4.1] | 0.0913 | S1: +1.9%, S2: +4.1% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +4.9% | [-41.2, +51.1] | [+0.8, +9.1] | 0.756 | S1: +0.8%, S2: +9.1% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +4.6% | [+2.8, +6.4] | [+4.1, +5.1] | 0.00369 | S1: +4.1%, S2: +5.1% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -0.5% | [-6.5, +5.4] | [-0.7, -0.4] | 0.792 | S1: -0.7%, S2: -0.4% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +8.7% | [+7.9, +9.5] | [+8.7, +8.7] | 6.14e-05 | S1: +8.7%, S2: +8.7% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +8.7% | [-34.3, +51.6] | [-8.3, +25.6] | 0.567 | S1: -8.3%, S2: +25.6% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +16.2% | [+12.2, +20.1] | [+14.7, +17.6] | 0.000983 | S1: +14.7%, S2: +17.6% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -0.8% | [-3.5, +1.9] | [-2.2, +0.6] | 0.413 | S1: -2.2%, S2: +0.6% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +27.4% | [+23.5, +31.3] | [+25.8, +29.0] | 0.000198 | S1: +25.8%, S2: +29.0% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +55.8% | [+51.2, +60.3] | [+54.4, +57.1] | 3.76e-05 | S1: +54.4%, S2: +57.1% |

## Point: rate=300/s, mrpc=5

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 2922.9 | 30.4 | [2874.5, 2971.4] |
| mtls1.3-postquantum-full | 4 | 3179.6 | 28.9 | [3133.7, 3225.6] |
| mtls1.3-x25519 | 4 | 2854.9 | 21.2 | [2821.2, 2888.7] |
| mtls1.3-x25519-full | 4 | 3108.3 | 9.7 | [3092.9, 3123.8] |
| plaintext | 4 | 2185.1 | 18.8 | [2155.2, 2215.0] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 318.6 | 5.2 | [310.4, 326.9] |
| mtls1.3-postquantum-full | 4 | 320.0 | 9.2 | [305.3, 334.7] |
| mtls1.3-x25519 | 4 | 316.4 | 8.3 | [303.2, 329.6] |
| mtls1.3-x25519-full | 4 | 320.8 | 9.8 | [305.2, 336.4] |
| plaintext | 4 | 316.6 | 9.0 | [302.3, 331.0] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 3.0 | 0.1 | [2.8, 3.1] |
| mtls1.3-postquantum-full | 4 | 3.0 | 0.1 | [2.9, 3.2] |
| mtls1.3-x25519 | 4 | 3.0 | 0.1 | [2.8, 3.1] |
| mtls1.3-x25519-full | 4 | 3.0 | 0.1 | [2.9, 3.1] |
| plaintext | 4 | 2.7 | 0.1 | [2.6, 2.8] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 20.9 | 1.6 | [18.3, 23.5] |
| mtls1.3-postquantum-full | 4 | 27.6 | 4.3 | [20.8, 34.4] |
| mtls1.3-x25519 | 4 | 20.2 | 1.7 | [17.4, 22.9] |
| mtls1.3-x25519-full | 4 | 26.1 | 1.6 | [23.5, 28.6] |
| plaintext | 4 | 9.8 | 0.4 | [9.2, 10.4] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 4 | +30.7% | [+27.9, +33.4] | [+29.9, +31.5] | 4.75e-05 | S1: +31.5%, S2: +29.9% |
| window_rps | mtls1.3-x25519 | plaintext | 4 | +0.0% | [-7.5, +7.5] | [-0.6, +0.6] | 1 | S1: +0.6%, S2: -0.6% |
| p50_ms | mtls1.3-x25519 | plaintext | 4 | +9.3% | [+8.2, +10.3] | [+8.9, +9.7] | 0.000101 | S1: +8.9%, S2: +9.7% |
| p99_ms | mtls1.3-x25519 | plaintext | 4 | +105.8% | [+71.7, +139.9] | [+91.2, +120.5] | 0.00221 | S1: +120.5%, S2: +91.2% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 4 | +42.3% | [+40.5, +44.0] | [+42.2, +42.3] | 4.73e-06 | S1: +42.3%, S2: +42.2% |
| window_rps | mtls1.3-x25519-full | plaintext | 4 | +1.3% | [-3.8, +6.5] | [+0.6, +2.1] | 0.471 | S1: +0.6%, S2: +2.1% |
| p50_ms | mtls1.3-x25519-full | plaintext | 4 | +11.1% | [+10.6, +11.7] | [+11.0, +11.2] | 6.37e-06 | S1: +11.2%, S2: +11.0% |
| p99_ms | mtls1.3-x25519-full | plaintext | 4 | +166.3% | [+128.1, +204.4] | [+147.0, +185.5] | 0.000813 | S1: +185.5%, S2: +147.0% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +8.9% | [+7.3, +10.4] | [+8.2, +9.5] | 0.000359 | S1: +8.2%, S2: +9.5% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +1.4% | [-2.9, +5.8] | [-0.0, +2.8] | 0.379 | S1: -0.0%, S2: +2.8% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +1.7% | [+0.4, +3.0] | [+1.2, +2.2] | 0.0247 | S1: +2.2%, S2: +1.2% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +29.6% | [+17.7, +41.6] | [+29.2, +30.1] | 0.00426 | S1: +30.1%, S2: +29.2% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +2.3% | [+0.8, +3.7] | [+1.8, +2.8] | 0.0152 | S1: +1.8%, S2: +2.8% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -0.2% | [-4.2, +3.8] | [-0.5, +0.1] | 0.872 | S1: -0.5%, S2: +0.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +0.9% | [-0.7, +2.5] | [+0.4, +1.3] | 0.176 | S1: +0.4%, S2: +1.3% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +6.0% | [-18.6, +30.6] | [+2.0, +10.0] | 0.494 | S1: +2.0%, S2: +10.0% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +2.4% | [+0.1, +4.7] | [+1.9, +2.9] | 0.0474 | S1: +1.9%, S2: +2.9% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +0.7% | [-1.2, +2.7] | [+0.3, +1.1] | 0.323 | S1: +1.1%, S2: +0.3% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +0.0% | [-0.4, +0.5] | [-0.1, +0.2] | 0.785 | S1: -0.1%, S2: +0.2% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +3.9% | [-8.6, +16.4] | [-1.8, +9.6] | 0.394 | S1: -1.8%, S2: +9.6% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +8.8% | [+7.2, +10.4] | [+8.2, +9.4] | 0.000406 | S1: +8.2%, S2: +9.4% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +0.4% | [-5.2, +6.1] | [-1.7, +2.6] | 0.816 | S1: -1.7%, S2: +2.6% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +2.5% | [+2.1, +3.0] | [+2.4, +2.7] | 0.000392 | S1: +2.7%, S2: +2.4% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +32.1% | [+4.1, +60.2] | [+30.4, +33.8] | 0.0357 | S1: +33.8%, S2: +30.4% |

## Point: rate=400/s, mrpc=0

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 1972.6 | 17.3 | [1945.0, 2000.1] |
| mtls1.3-postquantum-full | 4 | 1963.8 | 11.0 | [1946.2, 1981.3] |
| mtls1.3-x25519 | 4 | 1993.0 | 47.4 | [1917.6, 2068.4] |
| mtls1.3-x25519-full | 4 | 1962.6 | 12.3 | [1942.9, 1982.2] |
| plaintext | 4 | 1821.7 | 7.3 | [1810.1, 1833.3] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 426.1 | 10.3 | [409.7, 442.5] |
| mtls1.3-postquantum-full | 4 | 418.0 | 13.4 | [396.7, 439.4] |
| mtls1.3-x25519 | 4 | 427.5 | 5.2 | [419.2, 435.8] |
| mtls1.3-x25519-full | 4 | 423.5 | 13.8 | [401.6, 445.5] |
| plaintext | 4 | 416.9 | 2.8 | [412.4, 421.4] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 2.5 | 0.1 | [2.4, 2.6] |
| mtls1.3-postquantum-full | 4 | 2.5 | 0.1 | [2.4, 2.6] |
| mtls1.3-x25519 | 4 | 2.5 | 0.1 | [2.4, 2.6] |
| mtls1.3-x25519-full | 4 | 2.5 | 0.1 | [2.4, 2.6] |
| plaintext | 4 | 2.4 | 0.0 | [2.4, 2.5] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 9.6 | 0.7 | [8.5, 10.7] |
| mtls1.3-postquantum-full | 4 | 9.5 | 0.6 | [8.5, 10.5] |
| mtls1.3-x25519 | 4 | 9.6 | 1.3 | [7.6, 11.7] |
| mtls1.3-x25519-full | 4 | 10.1 | 1.9 | [7.1, 13.1] |
| plaintext | 4 | 8.8 | 0.6 | [7.9, 9.7] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 4 | +9.4% | [+4.7, +14.1] | [+8.4, +10.4] | 0.00795 | S1: +8.4%, S2: +10.4% |
| window_rps | mtls1.3-x25519 | plaintext | 4 | +2.6% | [-0.4, +5.5] | [+1.9, +3.2] | 0.073 | S1: +1.9%, S2: +3.2% |
| p50_ms | mtls1.3-x25519 | plaintext | 4 | +3.3% | [+1.8, +4.8] | [+2.9, +3.7] | 0.00592 | S1: +2.9%, S2: +3.7% |
| p99_ms | mtls1.3-x25519 | plaintext | 4 | +10.1% | [-17.4, +37.5] | [+8.0, +12.2] | 0.328 | S1: +8.0%, S2: +12.2% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 4 | +7.7% | [+7.3, +8.2] | [+7.6, +7.9] | 1.32e-05 | S1: +7.6%, S2: +7.9% |
| window_rps | mtls1.3-x25519-full | plaintext | 4 | +1.6% | [-3.9, +7.1] | [-1.2, +4.5] | 0.422 | S1: -1.2%, S2: +4.5% |
| p50_ms | mtls1.3-x25519-full | plaintext | 4 | +2.9% | [+1.8, +4.1] | [+2.4, +3.5] | 0.00384 | S1: +2.4%, S2: +3.5% |
| p99_ms | mtls1.3-x25519-full | plaintext | 4 | +14.9% | [-13.5, +43.4] | [+5.6, +24.2] | 0.194 | S1: +24.2%, S2: +5.6% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -1.5% | [-5.9, +2.9] | [-2.2, -0.7] | 0.361 | S1: -0.7%, S2: -2.2% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -0.9% | [-5.2, +3.4] | [-3.1, +1.2] | 0.539 | S1: -3.1%, S2: +1.2% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -0.4% | [-1.8, +1.1] | [-0.5, -0.2] | 0.459 | S1: -0.5%, S2: -0.2% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +6.1% | [-26.5, +38.8] | [-2.3, +14.5] | 0.592 | S1: +14.5%, S2: -2.3% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +0.1% | [-0.1, +0.3] | [+0.0, +0.1] | 0.38 | S1: +0.0%, S2: +0.1% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -1.3% | [-4.0, +1.4] | [-2.0, -0.6] | 0.231 | S1: -0.6%, S2: -2.0% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +0.1% | [-0.6, +0.9] | [+0.0, +0.2] | 0.686 | S1: +0.2%, S2: +0.0% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -3.7% | [-31.6, +24.2] | [-13.3, +5.8] | 0.698 | S1: -13.3%, S2: +5.8% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -1.0% | [-4.2, +2.2] | [-1.2, -0.8] | 0.396 | S1: -0.8%, S2: -1.2% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -0.3% | [-4.5, +3.9] | [-0.7, +0.0] | 0.821 | S1: +0.0%, S2: -0.7% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +0.1% | [-1.4, +1.5] | [-0.1, +0.3] | 0.885 | S1: -0.1%, S2: +0.3% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +0.7% | [-17.8, +19.2] | [-2.1, +3.5] | 0.911 | S1: -2.1%, S2: +3.5% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -0.4% | [-1.8, +1.0] | [-0.9, +0.1] | 0.389 | S1: +0.1%, S2: -0.9% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -1.9% | [-5.6, +1.8] | [-3.7, -0.1] | 0.203 | S1: -3.7%, S2: -0.1% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -0.3% | [-1.2, +0.5] | [-0.5, -0.2] | 0.275 | S1: -0.2%, S2: -0.5% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | -0.8% | [-6.8, +5.1] | [-2.3, +0.6] | 0.682 | S1: +0.6%, S2: -2.3% |

## Point: rate=400/s, mrpc=2

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 4074.9 | 74.3 | [3956.7, 4193.1] |
| mtls1.3-postquantum-full | 4 | 4642.1 | 48.7 | [4564.6, 4719.7] |
| mtls1.3-x25519 | 4 | 3958.1 | 97.8 | [3802.4, 4113.8] |
| mtls1.3-x25519-full | 4 | 4477.6 | 35.4 | [4421.3, 4533.8] |
| plaintext | 4 | 2609.8 | 13.2 | [2588.8, 2630.7] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 418.2 | 8.4 | [404.9, 431.6] |
| mtls1.3-postquantum-full | 4 | 421.2 | 7.1 | [410.0, 432.5] |
| mtls1.3-x25519 | 4 | 429.1 | 12.6 | [409.1, 449.1] |
| mtls1.3-x25519-full | 4 | 426.2 | 10.4 | [409.7, 442.7] |
| plaintext | 4 | 426.3 | 9.8 | [410.6, 442.0] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 5.2 | 0.1 | [5.1, 5.3] |
| mtls1.3-postquantum-full | 4 | 7.0 | 0.1 | [6.7, 7.2] |
| mtls1.3-x25519 | 4 | 4.9 | 0.1 | [4.7, 5.1] |
| mtls1.3-x25519-full | 4 | 6.6 | 0.1 | [6.5, 6.7] |
| plaintext | 4 | 3.2 | 0.1 | [3.2, 3.3] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 67.2 | 16.4 | [41.2, 93.3] |
| mtls1.3-postquantum-full | 4 | 83.4 | 11.6 | [65.0, 101.9] |
| mtls1.3-x25519 | 4 | 73.0 | 22.1 | [37.9, 108.2] |
| mtls1.3-x25519-full | 4 | 68.7 | 4.9 | [60.8, 76.5] |
| plaintext | 4 | 15.5 | 2.0 | [12.3, 18.7] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 4 | +51.7% | [+45.2, +58.1] | [+49.2, +54.1] | 0.000133 | S1: +54.1%, S2: +49.2% |
| window_rps | mtls1.3-x25519 | plaintext | 4 | +0.7% | [-4.4, +5.7] | [-1.3, +2.6] | 0.696 | S1: -1.3%, S2: +2.6% |
| p50_ms | mtls1.3-x25519 | plaintext | 4 | +51.7% | [+46.4, +56.9] | [+50.4, +52.9] | 6.97e-05 | S1: +52.9%, S2: +50.4% |
| p99_ms | mtls1.3-x25519 | plaintext | 4 | +365.0% | [+199.7, +530.4] | [+352.1, +377.9] | 0.00592 | S1: +377.9%, S2: +352.1% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 4 | +71.6% | [+68.3, +74.9] | [+70.4, +72.7] | 6.59e-06 | S1: +72.7%, S2: +70.4% |
| window_rps | mtls1.3-x25519-full | plaintext | 4 | +0.0% | [-4.9, +5.0] | [-1.9, +1.9] | 0.995 | S1: -1.9%, S2: +1.9% |
| p50_ms | mtls1.3-x25519-full | plaintext | 4 | +102.6% | [+99.6, +105.6] | [+101.5, +103.6] | 1.7e-06 | S1: +103.6%, S2: +101.5% |
| p99_ms | mtls1.3-x25519-full | plaintext | 4 | +346.0% | [+286.7, +405.3] | [+345.8, +346.1] | 0.000341 | S1: +346.1%, S2: +345.8% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +13.2% | [+9.4, +16.9] | [+12.1, +14.2] | 0.00151 | S1: +12.1%, S2: +14.2% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -0.6% | [-4.9, +3.6] | [-0.7, -0.6] | 0.664 | S1: -0.6%, S2: -0.7% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +33.6% | [+29.2, +38.1] | [+33.2, +34.0] | 0.000159 | S1: +33.2%, S2: +34.0% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +0.2% | [-42.6, +43.0] | [-1.5, +1.9] | 0.992 | S1: +1.9%, S2: -1.5% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +3.7% | [+2.5, +4.8] | [+3.5, +3.9] | 0.002 | S1: +3.9%, S2: +3.5% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -1.1% | [-4.7, +2.4] | [-2.3, +0.0] | 0.389 | S1: +0.0%, S2: -2.3% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +5.8% | [+4.0, +7.6] | [+4.9, +6.7] | 0.00211 | S1: +4.9%, S2: +6.7% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +21.1% | [+6.0, +36.2] | [+13.0, +29.2] | 0.0211 | S1: +13.0%, S2: +29.2% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +3.0% | [-0.8, +6.7] | [+2.3, +3.7] | 0.0853 | S1: +2.3%, S2: +3.7% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -2.5% | [-6.8, +1.9] | [-4.9, -0.1] | 0.168 | S1: -0.1%, S2: -4.9% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +5.4% | [+2.2, +8.7] | [+4.8, +6.1] | 0.0128 | S1: +4.8%, S2: +6.1% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -2.5% | [-48.9, +43.9] | [-12.1, +7.1] | 0.876 | S1: -12.1%, S2: +7.1% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +13.9% | [+10.9, +16.9] | [+13.8, +14.0] | 0.000668 | S1: +13.8%, S2: +14.0% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +0.8% | [-4.5, +6.0] | [-0.5, +2.0] | 0.674 | S1: -0.5%, S2: +2.0% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +34.1% | [+32.5, +35.6] | [+33.3, +34.8] | 6.79e-06 | S1: +33.3%, S2: +34.8% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +26.7% | [-0.6, +54.0] | [+20.7, +32.7] | 0.0526 | S1: +32.7%, S2: +20.7% |

## Point: rate=400/s, mrpc=5

### cpu_per_req_us

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 2889.5 | 19.8 | [2858.0, 2921.0] |
| mtls1.3-postquantum-full | 4 | 3087.9 | 22.1 | [3052.7, 3123.0] |
| mtls1.3-x25519 | 4 | 2852.6 | 23.3 | [2815.4, 2889.7] |
| mtls1.3-x25519-full | 4 | 3039.6 | 11.8 | [3020.9, 3058.3] |
| plaintext | 4 | 2138.5 | 18.2 | [2109.5, 2167.6] |

### window_rps

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 417.3 | 3.1 | [412.3, 422.2] |
| mtls1.3-postquantum-full | 4 | 421.8 | 11.7 | [403.1, 440.4] |
| mtls1.3-x25519 | 4 | 427.6 | 12.8 | [407.3, 447.9] |
| mtls1.3-x25519-full | 4 | 423.5 | 13.6 | [401.9, 445.1] |
| plaintext | 4 | 424.9 | 5.9 | [415.5, 434.4] |

### p50_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 3.1 | 0.1 | [3.0, 3.3] |
| mtls1.3-postquantum-full | 4 | 3.2 | 0.1 | [3.1, 3.3] |
| mtls1.3-x25519 | 4 | 3.1 | 0.1 | [3.0, 3.2] |
| mtls1.3-x25519-full | 4 | 3.2 | 0.1 | [3.1, 3.4] |
| plaintext | 4 | 2.7 | 0.0 | [2.7, 2.8] |

### p99_ms

| setup | n | mean | std | 95% CI |
|---|---|---|---|---|
| mtls1.3-postquantum | 4 | 38.5 | 11.4 | [20.4, 56.6] |
| mtls1.3-postquantum-full | 4 | 54.8 | 10.7 | [37.7, 71.8] |
| mtls1.3-x25519 | 4 | 38.6 | 7.0 | [27.4, 49.8] |
| mtls1.3-x25519-full | 4 | 43.1 | 5.6 | [34.3, 52.0] |
| plaintext | 4 | 11.4 | 0.9 | [10.0, 12.8] |

### Pairwise comparisons (paired t-test on same session and run)

| metric | A | B | pairs | diff A vs B | 95% CI (t) | 95% CI (sessions) | p-value | per session |
|---|---|---|---|---|---|---|---|---|
| cpu_per_req_us | mtls1.3-x25519 | plaintext | 4 | +33.4% | [+31.2, +35.6] | [+33.3, +33.4] | 2.05e-05 | S1: +33.3%, S2: +33.4% |
| window_rps | mtls1.3-x25519 | plaintext | 4 | +0.6% | [-4.6, +5.9] | [-1.5, +2.7] | 0.726 | S1: -1.5%, S2: +2.7% |
| p50_ms | mtls1.3-x25519 | plaintext | 4 | +14.5% | [+12.0, +16.9] | [+14.0, +15.0] | 0.00033 | S1: +14.0%, S2: +15.0% |
| p99_ms | mtls1.3-x25519 | plaintext | 4 | +240.5% | [+140.0, +341.0] | [+209.9, +271.2] | 0.0047 | S1: +271.2%, S2: +209.9% |
| cpu_per_req_us | mtls1.3-x25519-full | plaintext | 4 | +42.1% | [+39.8, +44.5] | [+41.0, +43.3] | 1.22e-05 | S1: +41.0%, S2: +43.3% |
| window_rps | mtls1.3-x25519-full | plaintext | 4 | -0.3% | [-6.3, +5.7] | [-3.1, +2.5] | 0.874 | S1: -3.1%, S2: +2.5% |
| p50_ms | mtls1.3-x25519-full | plaintext | 4 | +18.1% | [+16.2, +20.0] | [+17.4, +18.8] | 7.68e-05 | S1: +17.4%, S2: +18.8% |
| p99_ms | mtls1.3-x25519-full | plaintext | 4 | +280.7% | [+183.9, +377.4] | [+243.8, +317.6] | 0.00269 | S1: +243.8%, S2: +317.6% |
| cpu_per_req_us | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +6.6% | [+4.7, +8.4] | [+5.7, +7.4] | 0.00142 | S1: +5.7%, S2: +7.4% |
| window_rps | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | -1.0% | [-3.4, +1.5] | [-1.7, -0.2] | 0.306 | S1: -1.7%, S2: -0.2% |
| p50_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +3.2% | [+2.1, +4.4] | [+3.0, +3.4] | 0.00299 | S1: +3.0%, S2: +3.4% |
| p99_ms | mtls1.3-x25519-full | mtls1.3-x25519 | 4 | +14.4% | [-26.2, +55.0] | [-7.0, +35.9] | 0.34 | S1: -7.0%, S2: +35.9% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +1.6% | [-0.2, +3.4] | [+0.7, +2.5] | 0.0639 | S1: +2.5%, S2: +0.7% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -0.4% | [-4.6, +3.9] | [-1.9, +1.2] | 0.803 | S1: +1.2%, S2: -1.9% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | -0.8% | [-1.6, +0.1] | [-0.8, -0.7] | 0.0628 | S1: -0.8%, S2: -0.7% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-x25519-full | 4 | +26.8% | [-2.6, +56.2] | [+19.9, +33.7] | 0.0623 | S1: +33.7%, S2: +19.9% |
| cpu_per_req_us | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +1.3% | [-0.4, +3.0] | [+0.6, +2.0] | 0.0927 | S1: +0.6%, S2: +2.0% |
| window_rps | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -2.3% | [-7.7, +3.0] | [-4.3, -0.4] | 0.26 | S1: -0.4%, S2: -4.3% |
| p50_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | -0.0% | [-2.4, +2.3] | [-0.7, +0.6] | 0.957 | S1: -0.7%, S2: +0.6% |
| p99_ms | mtls1.3-postquantum | mtls1.3-x25519 | 4 | +1.6% | [-56.0, +59.2] | [-15.0, +18.2] | 0.934 | S1: -15.0%, S2: +18.2% |
| cpu_per_req_us | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +6.9% | [+4.8, +9.0] | [+6.0, +7.8] | 0.00186 | S1: +7.8%, S2: +6.0% |
| window_rps | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +1.1% | [-2.8, +5.0] | [-0.1, +2.2] | 0.443 | S1: -0.1%, S2: +2.2% |
| p50_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +2.5% | [+0.6, +4.4] | [+2.0, +3.0] | 0.0261 | S1: +3.0%, S2: +2.0% |
| p99_ms | mtls1.3-postquantum-full | mtls1.3-postquantum | 4 | +46.5% | [+9.8, +83.1] | [+46.4, +46.5] | 0.0274 | S1: +46.4%, S2: +46.5% |

## TLS session resumption

| setup | handshakes | reused | reused share | conn errors |
|---|---|---|---|---|
| mtls1.3-postquantum | 241374 | 382383 | 79.2% | 0 |
| mtls1.3-postquantum-full | 199668 | 0 | 0.0% | 0 |
| mtls1.3-x25519 | 227758 | 366329 | 80.4% | 0 |
| mtls1.3-x25519-full | 185852 | 0 | 0.0% | 0 |

## Key exchange verification (curve_evidence.csv)

| setup | windows | PASS | FAIL |
|---|---|---|---|
| mtls1.3-postquantum | 64 | 48 | 0 |
| mtls1.3-postquantum-full | 64 | 48 | 0 |
| mtls1.3-x25519 | 64 | 50 | 0 |
| mtls1.3-x25519-full | 64 | 48 | 0 |
