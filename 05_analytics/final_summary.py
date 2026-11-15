"""Summary of the final grid campaign (Istio 1.31.4, 4 sessions x 2 runs), stdlib only.

Unit of replication: one run = one block per (rate, mrpc); all setups of a block run back to
back in one machine state, so every comparison is a ratio or difference of two setups in the
same block, then averaged over the 8 runs (95% CI from t with n-1 df).
Blocks where the machine state flipped inside the block and back (missed by the exit canary)
are detected as outliers of the PQ-vs-X ratio (|ratio - median| > 4 * MAD of that point)
and reported; the tables show mean over all runs and the median as a robust check.

Usage: python3 -I 05_analytics/final_summary.py [04_results/Final_grid] [extra_dir_for_turbo_check]
"""
import csv
import os
import statistics as st
import sys
from collections import Counter, defaultdict

T95 = {2: 12.706, 3: 4.303, 4: 3.182, 5: 2.776, 6: 2.571, 7: 2.447, 8: 2.365, 9: 2.306, 10: 2.262}
X, XF, PQ, PQF, PL = ("mtls1.3-x25519", "mtls1.3-x25519-full", "mtls1.3-postquantum",
                      "mtls1.3-postquantum-full", "plaintext")


def load(d, replace=True):
    """-> (ok rows, blocks); blocks: (session, run, rate, mrpc) -> setup -> row.
    replacements.csv (orig_session,orig_run,rate,mrpc,repl_session,repl_run) maps a re-measured
    block onto the key of the block it replaces; with replace=False the originals are returned."""
    rows = [r for r in csv.DictReader(open(f"{d}/sweeps.csv")) if r["block_status"] == "ok"]
    blocks = defaultdict(dict)
    for r in rows:
        blocks[(r["session"], r["run"], int(r["rate_target"]), int(r["mrpc"]))][r["setup"]] = r
    path = f"{d}/replacements.csv"
    repl_keys = set()
    if os.path.exists(path):
        for m in csv.DictReader(open(path)):
            new = (m["repl_session"], m["repl_run"], int(m["rate"]), int(m["mrpc"]))
            old = (m["orig_session"], m["orig_run"], int(m["rate"]), int(m["mrpc"]))
            repl_keys.add(new)
            if replace and new in blocks:
                blocks[old] = blocks[new]
    for k in repl_keys:                              # replacement blocks never count as runs of their own
        blocks.pop(k, None)
    blocks = {k: dict(v, _key=k) for k, v in blocks.items()}   # every block knows its own key
    return rows, blocks


def hs_cost(blocks, b, a, ref, val=lambda r: float(r["cpu_per_req_us"])):
    """CPU per handshake [us] of setup a over setup ref in block b (mrpc = m):
        [(a - ref)(m) - (a - ref)(keep-alive)] * m
    The keep-alive block of the same run and offered load removes the per-request part of the
    difference (record encryption, ~140 us/request for TLS vs plaintext), which would otherwise
    be multiplied by m. With ref = plaintext this is the cost of one TLS handshake; with
    ref = X25519 it is the post-quantum add-on per handshake. None if no keep-alive partner."""
    s, r, rate, m = b["_key"]
    ka = blocks.get((s, r, rate, 0))
    if m == 0 or ka is None:
        return None
    return ((val(b[a]) - val(b[ref])) - (val(ka[a]) - val(ka[ref]))) * m


def f(r, k):
    return float(r[k])


def ci(v):
    n = len(v)
    m = st.mean(v)
    h = T95[n] * st.stdev(v) / n ** 0.5 if n > 1 else float("nan")
    return m, h


def points(blocks):
    return sorted({(k[2], k[3]) for k in blocks}, key=lambda p: (p[1] == 0, p[1], p[0]))


def label(p):
    return f"{p[0]}:{p[1] if p[1] else 'inf'}"


def quality(d, rows, blocks):
    allrows = list(csv.DictReader(open(f"{d}/sweeps.csv")))
    gate = list(csv.DictReader(open(f"{d}/gate.csv")))
    print(f"## Data quality ({d})")
    print(f"windows ok={len(rows)} (per setup {dict(Counter(r['setup'] for r in rows))})")
    print(f"blocks ok={len(blocks)}, rows by status {dict(Counter(r['block_status'] for r in allrows))}")
    for s in sorted({r["session"] for r in allrows}):
        g = [r for r in gate if r["session"] == s]
        c = sorted(f(r, "calib_ms") for r in rows if r["session"] == s)
        print(f"  session {s}: entry {dict(Counter(r['result'] for r in g if r['phase'] == 'enter'))}, "
              f"exit {dict(Counter(r['result'] for r in g if r['phase'] == 'exit'))}, "
              f"calib_ms p10/p50/p90 {c[len(c)//10]:.0f}/{c[len(c)//2]:.0f}/{c[9*len(c)//10]:.0f}")
    print(f"conn_errors={sum(int(r['conn_errors']) for r in rows)}, "
          f"windows with failed requests={sum(f(r, 'fail_rate') > 0 for r in rows)} "
          f"(max rate {max(f(r, 'fail_rate') for r in rows):.5f}), "
          f"dropped iterations={sum(f(r, 'dropped_iters') > 0 for r in rows)}")
    print(f"plaintext windows with handshakes={sum(1 for r in rows if r['setup'] == PL and int(r['handshakes']))}, "
          f"full-handshake windows with resumption={sum(1 for r in rows if r['setup'] in (XF, PQF) and int(r['session_reused']))}")
    share = [int(r["session_reused"]) / (2 * int(r["handshakes"]))
             for r in rows if r["setup"] in (X, PQ) and int(r["handshakes"])]
    print(f"resumed share (resumed arms, max_session_keys=16): min {min(share):.3f}, median {st.median(share):.3f}")
    ev = list(csv.DictReader(open(f"{d}/curve_evidence.csv")))
    print(f"curve evidence: {dict(Counter(r['verdict'] for r in ev))}\n")


def outliers(blocks):
    """Blocks whose PQ/X ratio (full or resumed) is far from the other runs of the same point."""
    bad = set()
    for p in points(blocks):
        ks = [k for k in blocks if k[2:] == p]
        for a, b in ((PQF, XF), (PQ, X)):
            v = {k: f(blocks[k][a], "cpu_per_req_us") / f(blocks[k][b], "cpu_per_req_us") for k in ks}
            med = st.median(v.values())
            mad = st.median(abs(x - med) for x in v.values()) or 1e-9
            bad |= {(k, a, round((x / med - 1) * 100, 1)) for k, x in v.items() if abs(x - med) > 4 * mad and abs(x / med - 1) > 0.05}
    return bad


def table_pct(blocks, pairs, drop=frozenset(), title=""):
    print(f"## {title}")
    print("CPU per request of both sidecars, change [%] = mean ± 95% CI over runs (median in brackets)")
    print(f"{'point':>8} | " + " | ".join(f"{n:>24}" for n in pairs))
    for p in points(blocks):
        cells = []
        for a, b in pairs.values():
            ks = [k for k in blocks if k[2:] == p and k not in drop]
            v = [(f(blocks[k][a], "cpu_per_req_us") / f(blocks[k][b], "cpu_per_req_us") - 1) * 100 for k in ks]
            m, h = ci(v)
            cells.append(f"{m:+6.1f} ±{h:4.1f} ({st.median(v):+5.1f}) n={len(v)}")
        print(f"{label(p):>8} | " + " | ".join(f"{c:>24}" for c in cells))
    print()


def table_handshake_cost(blocks, drop):
    """CPU per handshake [us], see hs_cost()."""
    print("## Cost of one handshake (both sidecars) [us] = [(TLS - plaintext)(mrpc) - (TLS - plaintext)(keep-alive)] x mrpc,"
          " mean ± 95% CI")
    print(f"{'point':>8} | {'X25519 full':>14} | {'PQ full':>14} | {'PQ - X full':>12} | {'X resumed':>14} | {'PQ resumed':>14} | {'PQ - X res':>12}")
    for p in points(blocks):
        if p[1] == 0:
            continue
        ks = [k for k in blocks if k[2:] == p and k not in drop]
        c = lambda s: [v for k in ks if (v := hs_cost(blocks, blocks[k], s, PL)) is not None]
        d = lambda a, b: [v for k in ks if (v := hs_cost(blocks, blocks[k], a, b)) is not None]
        cells = [ci(c(XF)), ci(c(PQF)), ci(d(PQF, XF)), ci(c(X)), ci(c(PQ)), ci(d(PQ, X))]
        print(f"{label(p):>8} | " + " | ".join(f"{m:7.0f} ±{h:4.0f}" for m, h in cells))
    print()


def table_latency(blocks, drop):
    print("## Latency p50 / p99 [ms], median over runs (k6, whole 60 s test)")
    order = [PL, XF, PQF, X, PQ]
    print(f"{'point':>8} | " + " | ".join(f"{s.replace('mtls1.3-', ''):>16}" for s in order))
    for p in points(blocks):
        ks = [k for k in blocks if k[2:] == p and k not in drop]
        cells = [f"{st.median(f(blocks[k][s], 'p50_ms') for k in ks):5.2f} / {st.median(f(blocks[k][s], 'p99_ms') for k in ks):5.1f}" for s in order]
        print(f"{label(p):>8} | " + " | ".join(f"{c:>16}" for c in cells))
    print()


def table_memory(blocks):
    print("## Sidecar memory [MiB], mean over blocks per mrpc (cgroup client / server, Envoy allocated server)")
    order = [PL, XF, PQF, X, PQ]
    for m in (1, 2, 5, 0):
        ks = [k for k in blocks if k[3] == m]
        cells = [f"{st.mean(f(blocks[k][s], 'mem_cg_client_mib') for k in ks):4.1f}/{st.mean(f(blocks[k][s], 'mem_cg_server_mib') for k in ks):4.1f}/{st.mean(f(blocks[k][s], 'mem_alloc_server_mib') for k in ks):3.1f}" for s in order]
        print(f"mrpc={m if m else 'inf':<4}" + "  ".join(f"{s.replace('mtls1.3-', ''):>17}: {c}" for s, c in zip(order, cells)))
    for key in ("mem_cg_server_mib", "mem_cg_client_mib", "mem_alloc_server_mib"):
        v = [f(b[PQF], key) - f(b[XF], key) for b in blocks.values()]
        m, h = st.mean(v), 1.96 * st.stdev(v) / len(v) ** 0.5     # n=112 blocks, normal approx.
        print(f"PQ full - X25519 full, {key}: {m:+.3f} ± {h:.3f} MiB (n={len(v)} blocks)")
    print()


def main():
    d = sys.argv[1] if len(sys.argv) > 1 else "04_results/Final_grid"
    rows, blocks = load(d)
    quality(d, rows, blocks)
    bad = outliers(blocks)
    drop = {k for k, _, _ in bad}
    print("## Outlier blocks (state flip inside the block): " +
          (", ".join(f"s{k[0]} run{k[1]} {label(k[2:])} {a.replace('mtls1.3-', '')} {x:+.1f}%" for k, a, x in sorted(bad)) or "none"))
    print("   tables below exclude them (the median column is robust either way)\n")
    table_pct(blocks, {"PQ full vs X25519 full": (PQF, XF), "PQ resumed vs X resumed": (PQ, X)}, drop,
              "Post-quantum key exchange overhead (X25519MLKEM768 vs X25519)")
    table_pct(blocks, {"X25519 full vs plaintext": (XF, PL), "X25519 resumed vs plain": (X, PL),
                       "PQ full vs plaintext": (PQF, PL)}, drop, "mTLS overhead vs plaintext")
    table_handshake_cost(blocks, drop)
    table_latency(blocks, drop)
    table_memory(blocks)
    if len(sys.argv) > 2:                                   # turbo-on session as a sensitivity check
        _, tb = load(sys.argv[2])
        tbad = {k for k, _, _ in outliers(tb)}
        table_pct(tb, {"PQ full vs X25519 full": (PQF, XF), "PQ resumed vs X resumed": (PQ, X)}, tbad,
                  f"Sensitivity: same comparison with turbo ON ({sys.argv[2]})")


if __name__ == "__main__":
    main()
