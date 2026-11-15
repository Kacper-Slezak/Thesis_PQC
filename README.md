# Post-quantum mTLS in an Istio service mesh: CPU, latency and memory overhead

Engineering thesis measurements. The question: how much does the hybrid post-quantum key
exchange **X25519MLKEM768** cost compared with classic **X25519** in Istio sidecar mTLS, for full
and resumed TLS 1.3 handshakes, as a function of requests per connection and offered load.

Final campaign: Istio 1.31.4 (Envoy 1.39.7, BoringSSL), k3d on WSL2, 4 sessions x 2 runs,
5 setups x 14 grid points, every comparison paired inside a block with a +-5% stability gate.
Data flow: [docs/pipeline_overview.png](docs/pipeline_overview.png),
analysis internals: [docs/pipeline_analysis.png](docs/pipeline_analysis.png)
(Mermaid sources `docs/*.mmd`).

## Requirements

| what | version used |
|---|---|
| Windows 11 + WSL2 (Ubuntu), AMD Ryzen AI 9 HX 370 | turbo **off** during measurements (`01_scripts/windows/stabilize_windows.ps1`, see below) |
| Docker, k3d | k3s v1.35.5 |
| istioctl | 1.31.4, unpacked to `./istio-1.31.4/` (not in git): `curl -L https://istio.io/downloadIstio \| ISTIO_VERSION=1.31.4 sh -` |
| kubectl, jq, bc | |
| Python | 3.12, `python3 -m venv .venv && .venv/bin/pip install -r requirements.txt` |

Images (pulled by the cluster): `istio/proxyv2:1.31.4`, `grafana/k6:1.3.0`,
`mccutchen/go-httpbin:2.18.3`. Sidecars are pinned to 2 CPU / 512 MiB.

**Machine stability.** The laptop switches between two performance levels (~17% apart) even with
turbo off; the method is built around that (blocks + gate, see `01_scripts/gate.sh`). Before every
measurement run `01_scripts/windows/stabilize_windows.ps1` in PowerShell as administrator
(separate "Thesis benchmark" power plan: CPU boost off, min/max processor state 100%, no core
parking, no sleep on AC; Windows Search and SysMain stopped; `-Restore` undoes everything) and check
`source 01_scripts/lib_setups.sh; calib_ms` gives ~360-430 ms (turbo on gives ~150-250 ms).
`run_all_final.sh` refuses to start below 300 ms and `run_sweeps.sh` waits before every block.

## Running the measurements

```bash
./run_all_final.sh s1 2>&1 | tee -a run_all_final.log   # one grid session (~8-10 h, fresh cluster)
./run_all_final.sh s2 s3 s4                              # remaining grid sessions
./run_all_final.sh fix                                   # 4 re-measured blocks (session 5)
./run_all_final.sh f2a f2b                               # classic TLS 1.2/1.3 cipher suites (~5 h)
```

| script | role |
|---|---|
| `run_all_final.sh` | steps `s1`..`s4`, `fix`, `f2a`, `f2b`; turbo check; `MAX_SESSION_KEYS=16` |
| `run_campaign.sh` | one session: `01_scripts/setup_cluster.sh`, `verify_ciphers.sh`, monitoring off, `run_sweeps.sh` |
| `run_sweeps.sh` | session gate, runs, blocks (`run_block`), one window per setup (`one_point`); resumes after a crash |
| `01_scripts/lib_setups.sh` | setups (EnvoyFilter / PeerAuthentication / DestinationRule), `measure_window`, CPU and memory snapshots |
| `01_scripts/gate.sh` | canary windows before/after each block, +-5% rule, session gate |
| `run_resumption.sh` | R1: resumed share vs client `max_session_keys` |
| `run_r2_capture.sh` | R2: tcpdump in the server pod, ClientHello/ServerHello with PSK (`05_analytics/r2_psk_count.py`) |
| `run_live.sh` | live demo with Prometheus/Grafana on, configuration switched every 5 min |

One window = 60 s k6 test at a constant arrival rate; CPU and Envoy counters are read at
10 s and 55 s (45 s window); latency percentiles come from k6 over the whole 60 s.

## Analysis

```bash
.venv/bin/python -I 05_analytics/final_summary.py > 04_results/Final_grid/summary.txt   # all tables
.venv/bin/python -I 05_analytics/robustness.py                                           # appendix checks
.venv/bin/python -I 05_analytics/plot_final.py [--no-titles]                             # grid figures
.venv/bin/python -I 05_analytics/plot_f2.py [--no-titles]                                # F2 figures
.venv/bin/python -I 05_analytics/plot_live.py 04_results/Live_20261115_1118              # live figures
```

Every comparison is a ratio or difference of two setups **inside one block** (same machine
state), then mean and 95% t-CI over the 8 runs. Cost of one handshake:
`[(A - B)(mrpc) - (A - B)(keep-alive)] x mrpc` (`hs_cost` in `final_summary.py`).

## Results layout (`04_results/`)

| directory | content |
|---|---|
| `Final_grid/` | main grid: `sweeps.csv`, `gate.csv`, `curve_evidence.csv`, `replacements.csv`, `summary.txt`, `robustness.txt`, `plots/`, `plots_latex/` |
| `Final_F2a_classic_handshake/`, `Final_F2b_classic_payload/` | classic cipher suites |
| `R1_resumption_*/`, `R2_capture_*/` | resumption diagnostics (pcap files are not in git) |
| `Live_*/` | live demo: Prometheus series, `plots/`, Grafana screenshots `grafana/` |
| `Archive/` | pilot and Istio 1.30.2 campaigns (F1-F3, M1), smoke test, turbo pilot; `final_prep_2026-11/Final_grid_s3_turbo` = session 3 measured with turbo on (sensitivity check only) |

### `sweeps.csv` columns (one row = one measurement window)

| column | meaning |
|---|---|
| `mode`, `setup`, `rate_target`, `mrpc` | grid mode, setup, offered load [req/s], max requests per connection (0 = unlimited) |
| `session`, `run`, `block_id`, `timestamp` | session (fresh cluster), run within session, block `s<S>_run<R>_r<rate>_m<mrpc>_a<attempt>`, UTC end of window |
| `window_rps`, `k6_rps` | requests/s in the 45 s window (Envoy) and over the whole test (k6) |
| `p50_ms`, `p95_ms`, `p99_ms` | k6 latency percentiles [ms] |
| `fail_rate`, `dropped_iters`, `conn_errors` | failed requests, k6 dropped iterations, TLS connection errors |
| `client_sidecar_cpu`, `server_sidecar_cpu` | mean CPU of each `istio-proxy` container in the window [cores] (cgroup `cpu.stat`) |
| `cpu_per_req_us` | (client + server CPU) / requests [µs]; main metric |
| `handshakes`, `handshakes_per_s` | TLS handshakes on the server sidecar |
| `session_reused` | resumed handshakes, client + server; resumed share = `session_reused / (2 x handshakes)` |
| `cpu_per_handshake_us` | raw CPU / handshakes (not used; see `hs_cost`) |
| `mem_*_mib` | memory of each sidecar: Envoy allocated, heap, cgroup `memory.current`; mean of window start/end and `_max` |
| `calib_ms` | host calibration loop [ms]; ~400 turbo off, ~160 turbo on |
| `max_session_keys`, `istio_version`, `cert_key` | client ticket slots, Istio version, certificate key type |
| `gate_entry`, `block_status` | entry canary vs reference (`first`/`ok`/`shifted`); block accepted (`ok`) or `rejected` |
| `gate_entry_dev_pct`, `gate_exit_dev_pct` | canary deviation at entry (vs session reference) and exit (vs entry) [%] |
| `fraction`, `netem_*` | unused (always 0) |

`gate.csv`: one row per canary window (`phase` = session / enter / exit) with `cpu_per_req_us`,
reference, deviation and result.
