"""Figures for the final campaign (Istio 1.31.4, grid 4 sessions x 2 runs), English labels.

Statistics as in final_summary.py (imported): one run = one block per (rate, mrpc) point;
comparisons are paired inside a block, then mean and 95% t-CI over runs; blocks with a
machine-state flip inside the block (final_summary.outliers) are left out.

Encoding: key exchange = hue (X25519 blue, X25519MLKEM768 orange, plaintext gray);
full vs resumed handshake = line style + marker (solid/circle vs dashed/triangle);
offered load = one-hue ordinal blue ramp. Machine state: fast = filled, slow = hollow.

Usage:
  .venv/bin/python -I 05_analytics/plot_final.py              # titles on  -> <grid>/plots/
  .venv/bin/python -I 05_analytics/plot_final.py --no-titles  # for LaTeX  -> <grid>/plots_latex/
Options: --grid DIR (default 04_results/Final_grid), --r1 DIR (R1 sweep directory).
Every multi-panel figure is also written one panel per file into <out>/single/.
Output: PNG (300 dpi) and PDF (vector) for each figure.
"""
import argparse
import csv
import os
import statistics as st
import sys
from collections import defaultdict

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from final_summary import PL, PQ, PQF, T95, X, XF, load, outliers  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument("--grid", default="04_results/Final_grid")
ap.add_argument("--r1", default="04_results/R1_resumption_20261109_1931")
ap.add_argument("--no-titles", action="store_true", help="no figure/panel titles (captions go to LaTeX)")
args = ap.parse_args()
TITLES = not args.no_titles
OUT = os.path.join(args.grid, "plots" if TITLES else "plots_latex")
SINGLE = os.path.join(OUT, "single")
os.makedirs(SINGLE, exist_ok=True)

# colours (validated: dataviz validate_palette.js "#2a78d6,#eb6834" light -> all checks pass)
BLUE, ORANGE, GRAY = "#2a78d6", "#eb6834", "#7a7974"
RAMP = ["#6da7ec", "#2a78d6", "#1c5cab", "#0d366b"]          # 100, 200, 300, 400 req/s
INK, INK2, GRID_C = "#0b0b0b", "#52514e", "#e4e3df"
STYLE = {  # setup -> (label, colour, linestyle, marker)
    PL:  ("plaintext",                 GRAY,   "-",  "s"),
    XF:  ("X25519, full",              BLUE,   "-",  "o"),
    X:   ("X25519, resumed",           BLUE,   "--", "^"),
    PQF: ("X25519MLKEM768, full",      ORANGE, "-",  "o"),
    PQ:  ("X25519MLKEM768, resumed",   ORANGE, "--", "^"),
}
ORDER = [PL, XF, X, PQF, PQ]
MRPCS = [1, 2, 5, 0]
RATES = [100, 200, 300, 400]
MLAB = {1: "1", 2: "2", 5: "5", 0: "∞"}
XL_MRPC, XL_RATE = "requests per connection (mrpc)", "offered load [req/s]"

plt.rcParams.update({
    "font.size": 9, "axes.titlesize": 9.5, "axes.labelsize": 9, "legend.fontsize": 8,
    "axes.edgecolor": INK2, "axes.labelcolor": INK, "xtick.color": INK2, "ytick.color": INK2,
    "axes.grid": True, "grid.color": GRID_C, "grid.linewidth": 0.6, "axes.axisbelow": True,
    "axes.spines.top": False, "axes.spines.right": False, "lines.linewidth": 2,
    "lines.markersize": 5.5, "errorbar.capsize": 2.5, "savefig.dpi": 300, "font.family": "DejaVu Sans",
})

rows, blocks = load(args.grid)
drop = {k for k, _, _ in outliers(blocks)}
B = {k: v for k, v in blocks.items() if k not in drop}          # (session, run, rate, mrpc) -> setup -> row

# machine state per block, from the entry canary relative to the lower level of the same point
gate = [r for r in csv.DictReader(open(os.path.join(args.grid, "gate.csv"))) if r["phase"] in ("enter", "exit")]
_lo = defaultdict(lambda: float("inf"))
for r in gate:
    _lo[(r["rate"], r["mrpc"])] = min(_lo[(r["rate"], r["mrpc"])], float(r["cpu_per_req_us"]))
STATE_GAP = 0.09                                                 # levels are ~0% and ~13-25% apart
STATE = {r["block_id"]: ("fast" if float(r["cpu_per_req_us"]) / _lo[(r["rate"], r["mrpc"])] - 1 < STATE_GAP else "slow")
         for r in gate if r["phase"] == "enter"}


def state_of(b):
    return STATE[next(iter(b.values()))["block_id"]]


# ----------------------------------------------------------------------------- helpers
def cpu(r):
    return float(r["cpu_per_req_us"])


def ci(v):
    n = len(v)
    return st.mean(v), (T95[n] * st.stdev(v) / n ** 0.5 if n > 1 else 0.0)


def iqr(v):
    q = st.quantiles(v, n=4) if len(v) > 1 else [v[0], v[0], v[0]]
    return st.median(v), q[0], q[2]


def at(rate, mrpc, bset=None):
    return [b for k, b in (bset or B).items() if k[2] == rate and k[3] == mrpc]


def per_run(mrpc, fn, bset=None):
    """Average fn(block) over the rates of one run, so each run gives one value per mrpc."""
    runs = defaultdict(list)
    for k, b in (bset or B).items():
        if k[3] == mrpc:
            runs[(k[0], k[1])].append(fn(b))
    return [st.mean(v) for v in runs.values()]


def title(obj, text, **kw):
    if TITLES:
        (obj.suptitle if hasattr(obj, "suptitle") else obj.set_title)(text, **kw)


def save(fig, name, single=False):
    d = SINGLE if single else OUT
    for ext in ("png", "pdf"):
        fig.savefig(os.path.join(d, f"{name}.{ext}"), bbox_inches="tight")
    plt.close(fig)
    print("wrote", os.path.join(d, name + ".png"))


def legend_below(fig, ax, ncol=5, y=-0.12):
    h, lab = ax.get_legend_handles_labels()
    fig.legend(h, lab, loc="lower center", ncol=ncol, frameon=False, bbox_to_anchor=(0.5, y))


def xcat(ax, labels, xlabel=None):
    ax.set_xticks(range(len(labels)))
    ax.set_xticklabels(labels)
    if xlabel:
        ax.set_xlabel(xlabel)


def multi_and_single(name, panels, draw, ylabel, xlabel, sup, figsize, single_size=(4.2, 3.2), ncol=5, sharey=True):
    """Draw the same panels once side by side and once one per file."""
    fig, axes = plt.subplots(1, len(panels), figsize=figsize, sharey=sharey)
    for ax, (key, ptitle) in zip(axes, panels):
        draw(ax, key)
        xcat_done = ax.get_xlabel()
        ax.set_xlabel("")
        if TITLES or len(panels) > 1:
            ax.set_title(ptitle)                       # panel titles identify panels; keep them
    axes[0].set_ylabel(ylabel)
    fig.supxlabel(xlabel, fontsize=9, y=-0.03)
    legend_below(fig, axes[0], ncol=ncol)
    title(fig, sup, fontsize=9.5, y=1.02)
    save(fig, name)
    for key, ptitle in panels:
        fig, ax = plt.subplots(figsize=single_size)
        draw(ax, key)
        ax.set_xlabel(xlabel)
        ax.set_ylabel(ylabel)
        title(ax, f"{ptitle}", fontsize=9)
        legend_below(fig, ax, ncol=2, y=-0.32)
        save(fig, f"{name}__{str(key).replace(' ', '')}", single=True)


# ----------------------------------------------------------------------------- panel drawers
def draw_cpu(ax, rate):
    for s in ORDER:
        lab, c, ls, mk = STYLE[s]
        xs, ys, es = [], [], []
        for i, m in enumerate(MRPCS):
            bl = at(rate, m)
            if bl:
                mu, h = ci([cpu(b[s]) for b in bl])
                xs.append(i); ys.append(mu / 1000); es.append(h / 1000)
        ax.errorbar(xs, ys, yerr=es, color=c, ls=ls, marker=mk, label=lab)
    xcat(ax, [MLAB[m] for m in MRPCS])


def draw_overhead(ax, which):
    a, b = (PQF, XF) if which == "full" else (PQ, X)
    for j, rate in enumerate(RATES):
        xs, ys, es = [], [], []
        for i, m in enumerate(MRPCS):
            bl = at(rate, m)
            if bl:
                mu, h = ci([(cpu(x[a]) / cpu(x[b]) - 1) * 100 for x in bl])
                xs.append(i + (j - 1.5) * 0.12); ys.append(mu); es.append(h)
        ax.errorbar(xs, ys, yerr=es, color=RAMP[j], ls="none", marker="o", label=f"{rate} req/s")
    ax.axhline(0, color=INK2, lw=0.8)
    xcat(ax, [MLAB[m] for m in MRPCS])


def draw_overhead_runs(ax, which):
    """Every run as a small dot, mean ± CI as a bar: shows the spread behind f2."""
    a, b = (PQF, XF) if which == "full" else (PQ, X)
    for j, rate in enumerate(RATES):
        for i, m in enumerate(MRPCS):
            bl = at(rate, m)
            if not bl:
                continue
            v = [(cpu(x[a]) / cpu(x[b]) - 1) * 100 for x in bl]
            x0 = i + (j - 1.5) * 0.17
            ax.plot([x0 - 0.04] * len(v), v, ls="none", marker="o", ms=2.6, color=RAMP[j], alpha=0.55)
            mu, h = ci(v)
            ax.errorbar([x0 + 0.03], [mu], yerr=[h], color=RAMP[j], marker="D", ms=4,
                        label=f"{rate} req/s" if i == 1 else None)
    ax.axhline(0, color=INK2, lw=0.8)
    xcat(ax, [MLAB[m] for m in MRPCS])


def draw_latency(ax, km):
    key, m = km
    for s in ORDER:
        lab, c, ls, mk = STYLE[s]
        xs, ys, lo, hi = [], [], [], []
        for i, rate in enumerate(RATES):
            bl = at(rate, m)
            if bl:
                med, q1, q3 = iqr([float(b[s][key]) for b in bl])
                xs.append(i + (ORDER.index(s) - 2) * 0.05); ys.append(med); lo.append(med - q1); hi.append(q3 - med)
        ax.errorbar(xs, ys, yerr=[lo, hi], color=c, ls=ls, marker=mk, label=lab)
    xcat(ax, [str(r) for r in RATES])


def draw_memory(ax, key):
    for j, s in enumerate(ORDER):
        lab, c, ls, mk = STYLE[s]
        ys, es = zip(*[ci(per_run(m, lambda b, s=s: float(b[s][key]))) for m in MRPCS])
        ax.errorbar([i + (j - 2) * 0.1 for i in range(4)], ys, yerr=es, color=c, ls="none", marker=mk,
                    label=lab, mfc="white" if ls == "--" else c)
    xcat(ax, [MLAB[m] for m in MRPCS])


# ----------------------------------------------------------------------------- figures
def fig_cpu():
    multi_and_single("f1_cpu_per_request", [(r, f"{r} req/s") for r in RATES], draw_cpu,
                     "sidecar CPU per request [ms]\n(client + server)", XL_MRPC,
                     "CPU cost per request (mean ± 95% CI, n = 8 runs; mrpc = 1 not measured at 300-400 req/s)",
                     (10, 3.2))


def fig_overhead():
    panels = [("full", "X25519MLKEM768 vs X25519, full handshake"), ("resumed", "X25519MLKEM768 vs X25519, resumed handshake")]
    multi_and_single("f2_pqc_overhead_pct", panels, draw_overhead, "change in CPU per request [%]", XL_MRPC,
                     "Post-quantum key exchange overhead (paired within block, mean ± 95% CI, n = 7-8 runs)",
                     (8, 3.2), ncol=4)
    multi_and_single("f2b_pqc_overhead_pct_runs", panels, draw_overhead_runs, "change in CPU per request [%]", XL_MRPC,
                     "Post-quantum overhead: every run (dots) and mean ± 95% CI (diamonds)",
                     (8, 3.4), ncol=4)


def fig_handshake_cost():
    fig, ax = plt.subplots(figsize=(6.4, 3.3))
    bars = [(XF, "X25519, full"), (PQF, "X25519MLKEM768, full"), (X, "X25519, resumed"), (PQ, "X25519MLKEM768, resumed")]
    w = 0.19
    for j, (s, lab) in enumerate(bars):
        _, c, ls, _ = STYLE[s]
        for i, m in enumerate([1, 2, 5]):
            mu, h = ci(per_run(m, lambda b, s=s, m=m: (cpu(b[s]) - cpu(b[PL])) * m))
            ax.bar(i + (j - 1.5) * w, mu / 1000, w * 0.9, yerr=h / 1000, color=c,
                   hatch="////" if ls == "--" else None, edgecolor="white", linewidth=0.6,
                   label=lab if i == 0 else None, error_kw={"ecolor": INK2, "lw": 1})
            if j in (1, 3):
                a, b = (PQF, XF) if j == 1 else (PQ, X)
                d, dh = ci(per_run(m, lambda x, a=a, b=b, m=m: (cpu(x[a]) - cpu(x[b])) * m))
                ax.text(i + (j - 1.5) * w, (mu + h) / 1000 + 0.12, f"+{d:.0f}\n±{dh:.0f} µs",
                        ha="center", va="bottom", fontsize=6.5, color=INK2)
    xcat(ax, ["1", "2", "5"], XL_MRPC)
    ax.set_ylabel("sidecar CPU per handshake [ms]")
    ax.set_ylim(0, 6.3)
    ax.legend(frameon=False, ncol=2, loc="upper left")
    title(ax, "CPU cost of one handshake (both sidecars), averaged over offered loads, mean ± 95% CI, n = 8 runs\n"
              "labels: post-quantum add-on per handshake", fontsize=8.5)
    save(fig, "f3_handshake_cost")


def fig_pq_addon_points():
    """PQ add-on per handshake [µs] at every grid point: is it really constant?"""
    fig, ax = plt.subplots(figsize=(7.4, 3.2))
    pts = [(r, m) for m in (1, 2, 5) for r in RATES if at(r, m)]
    for j, (a, b, lab, c, mk) in enumerate(((PQF, XF, "full handshake", ORANGE, "o"), (PQ, X, "resumed handshake", ORANGE, "^"))):
        ys, es = zip(*[ci([(cpu(x[a]) - cpu(x[b])) * m for x in at(r, m)]) for r, m in pts])
        ax.errorbar([i + (j - 0.5) * 0.2 for i in range(len(pts))], ys, yerr=es, color=c, ls="none", marker=mk,
                    mfc="white" if j else c, label=lab)
    allv = [(cpu(x[PQF]) - cpu(x[XF])) * m for r, m in pts for x in at(r, m)]
    ax.axhline(st.mean(allv), color=INK2, lw=0.8, ls=":")
    ax.axhline(0, color=INK2, lw=0.8)
    xcat(ax, [f"{r}\nmrpc {m}" for r, m in pts], "grid point (offered load [req/s], mrpc)")
    ax.set_ylabel("post-quantum add-on per handshake [µs]")
    legend_below(fig, ax, ncol=2, y=-0.2)
    title(ax, "Extra CPU per handshake for X25519MLKEM768 vs X25519 (both sidecars, mean ± 95% CI)\n"
              "dotted line: mean over all full-handshake points", fontsize=8.5)
    save(fig, "f3b_pq_addon_per_point")


def fig_cpu_split():
    """Which sidecar pays: client (k6) vs server (httpbin) CPU per request, mrpc = 1."""
    fig, axes = plt.subplots(1, 2, figsize=(8.6, 3.2), sharey=False, gridspec_kw={"wspace": 0.38})
    side = lambda b, s, k: float(b[s][k]) * 1e6 / float(b[s]["window_rps"])     # cores -> µs per request
    ax = axes[0]
    for j, s in enumerate(ORDER):
        lab, c, ls, _ = STYLE[s]
        for i, (k, nm) in enumerate((("client_sidecar_cpu", "client"), ("server_sidecar_cpu", "server"))):
            mu, h = ci(per_run(1, lambda b, s=s, k=k: side(b, s, k)))
            ax.bar(i + (j - 2) * 0.16, mu / 1000, 0.15, yerr=h / 1000, color=c, hatch="////" if ls == "--" else None,
                   edgecolor="white", linewidth=0.6, label=lab if i == 0 else None, error_kw={"ecolor": INK2, "lw": 1})
    xcat(ax, ["client sidecar (k6)", "server sidecar (httpbin)"])
    ax.set_ylabel("CPU per request [ms], mrpc = 1")
    if TITLES:
        ax.set_title("CPU per request by sidecar (mrpc = 1)")
    ax = axes[1]
    for i, (k, nm) in enumerate((("client_sidecar_cpu", "client"), ("server_sidecar_cpu", "server"))):
        for j, (a, b, lab, mk) in enumerate(((PQF, XF, "full", "o"), (PQ, X, "resumed", "^"))):
            v = [side(x, a, k) - side(x, b, k) for r in RATES for x in at(r, 1)]
            mu, h = ci(per_run(1, lambda x, a=a, b=b, k=k: side(x, a, k) - side(x, b, k)))
            ax.errorbar([i + (j - 0.5) * 0.2], [mu], yerr=[h], color=ORANGE, marker=mk, mfc="white" if j else ORANGE,
                        ls="none", label=f"{lab} handshake" if i == 0 else None)
    ax.axhline(0, color=INK2, lw=0.8)
    xcat(ax, ["client sidecar (k6)", "server sidecar (httpbin)"])
    ax.set_ylabel("post-quantum add-on per handshake [µs]")
    ax.legend(frameon=False)
    if TITLES:
        ax.set_title("Where the ML-KEM cost lands (mrpc = 1)")
    legend_below(fig, axes[0], ncol=5, y=-0.14)
    title(fig, "Client vs server sidecar (mean ± 95% CI over runs)", fontsize=9.5, y=1.03)
    save(fig, "f9_cpu_client_vs_server")


def fig_mtls_overhead():
    fig, ax = plt.subplots(figsize=(5.4, 3.3))
    for s in (XF, X, PQF, PQ):
        lab, c, ls, mk = STYLE[s]
        ys, es = zip(*[ci(per_run(m, lambda b, s=s: (cpu(b[s]) / cpu(b[PL]) - 1) * 100)) for m in MRPCS])
        ax.errorbar(range(4), ys, yerr=es, color=c, ls=ls, marker=mk, label=lab)
    xcat(ax, [MLAB[m] for m in MRPCS], XL_MRPC)
    ax.set_ylabel("CPU per request vs plaintext [%]")
    ax.set_ylim(bottom=0)
    ax.legend(frameon=False)
    title(ax, "mTLS overhead over plaintext, averaged over offered loads\n(mean ± 95% CI, n = 8 runs)", fontsize=9)
    save(fig, "f4_mtls_overhead_vs_plaintext")


def fig_latency():
    for key, nm, lab in (("p50_ms", "f5a_latency_p50", "latency p50 [ms]"),
                         ("p95_ms", "f5c_latency_p95", "latency p95 [ms]"),
                         ("p99_ms", "f5b_latency_p99", "latency p99 [ms]")):
        multi_and_single(nm, [((key, m), f"mrpc = {MLAB[m]}") for m in MRPCS], draw_latency, lab, XL_RATE,
                         f"Request latency {key[:3]} (median over 8 runs, bars = interquartile range; k6, whole 60 s test)",
                         (10, 3.0))


def fig_memory():
    multi_and_single("f6_memory", [("mem_cg_client_mib", "client sidecar (k6)"), ("mem_cg_server_mib", "server sidecar (httpbin)")],
                     draw_memory, "container memory (cgroup) [MiB]", XL_MRPC,
                     "Sidecar memory during the measurement window (mean ± 95% CI, n = 8 runs)", (8, 3.0))


def fig_states():
    lo = _lo
    fig, (ax, axh) = plt.subplots(1, 2, figsize=(9, 3.0), sharey=True, gridspec_kw={"width_ratios": [4, 1]})
    rel_all, x0 = [], 0
    for s in sorted({r["session"] for r in gate}):
        g = [r for r in gate if r["session"] == s]
        rel = [(float(r["cpu_per_req_us"]) / lo[(r["rate"], r["mrpc"])] - 1) * 100 for r in g]
        rel_all += rel
        ax.plot(range(x0, x0 + len(rel)), rel, ls="none", marker="o", ms=3.5, color=BLUE, alpha=0.8)
        ax.text(x0 + len(rel) / 2, 30.5, f"session {s}", ha="center", va="bottom", fontsize=8, color=INK2)
        x0 += len(rel)
        ax.axvline(x0 - 0.5, color=GRID_C, lw=1)
    ax.axhline(STATE_GAP * 100, color=INK2, lw=0.8, ls=":")
    ax.set_xlabel("canary window (entry and exit of every block, in time order)")
    ax.set_ylabel("canary CPU per request vs the lower level\nof the same (rate, mrpc) [%]")
    ax.set_ylim(-3, 30)
    title(ax, "Two machine levels with turbo off (canary = X25519 resumed); dotted: fast/slow threshold", fontsize=9, pad=16)
    axh.hist(rel_all, bins=30, range=(-3, 30), orientation="horizontal", color=BLUE, edgecolor="white")
    axh.set_xlabel("windows")
    axh.grid(False)
    save(fig, "f7_machine_states")


def fig_state_independence():
    """Share of fast-state blocks by offered load and by mrpc: the state does not follow the load."""
    fig, axes = plt.subplots(1, 2, figsize=(7, 2.8), sharey=True)
    for ax, (idx, labels, xl) in zip(axes, ((2, RATES, XL_RATE), (3, MRPCS, XL_MRPC))):
        share = []
        for v in labels:
            bl = [b for k, b in blocks.items() if k[idx] == v]
            share.append(100 * sum(state_of(b) == "fast" for b in bl) / len(bl))
        ax.bar(range(len(labels)), share, 0.6, color=BLUE, edgecolor="white")
        for i, sh in enumerate(share):
            ax.text(i, sh + 1, f"{sh:.0f}%", ha="center", fontsize=8, color=INK2)
        xcat(ax, [MLAB.get(v, str(v)) if idx == 3 else str(v) for v in labels], xl)
    axes[0].set_ylabel("blocks in the fast state [%]")
    axes[0].set_ylim(0, 50)
    title(fig, "Machine state vs measured load (all 112 blocks)", fontsize=9.5, y=1.02)
    save(fig, "f7b_state_vs_load")


def fig_overhead_by_state():
    """PQ overhead computed separately in fast and slow blocks: the paired ratio does not depend on the state."""
    fig, axes = plt.subplots(1, 2, figsize=(8, 3.2), sharey=True)
    for ax, (a, b, nm) in zip(axes, ((PQF, XF, "full handshake"), (PQ, X, "resumed handshake"))):
        counts = {m: [] for m in MRPCS}
        for j, stt in enumerate(("fast", "slow")):
            ys, es, xs, ns = [], [], [], []
            for i, m in enumerate(MRPCS):
                v = [(cpu(x[a]) / cpu(x[b]) - 1) * 100 for k, x in B.items() if k[3] == m and state_of(x) == stt]
                if len(v) >= 2:
                    mu, h = ci(v) if len(v) <= 10 else (st.mean(v), 1.96 * st.stdev(v) / len(v) ** 0.5)
                    xs.append(i + (j - 0.5) * 0.18); ys.append(mu); es.append(h); ns.append(len(v))
                counts[m].append(len(v))
            ax.errorbar(xs, ys, yerr=es, color=BLUE, ls="none", marker="o", mfc=BLUE if stt == "fast" else "white",
                        label=f"{stt} state")
        ax.axhline(0, color=INK2, lw=0.8)
        xcat(ax, [f"{MLAB[m]}\nn = {counts[m][0]} / {counts[m][1]}" for m in MRPCS])
        ax.set_title(f"X25519MLKEM768 vs X25519, {nm}")
    axes[0].set_ylabel("change in CPU per request [%]")
    fig.supxlabel(XL_MRPC + ";  n = blocks fast / slow", fontsize=9, y=-0.1)
    legend_below(fig, axes[0], ncol=2, y=-0.22)
    title(fig, "Post-quantum overhead in fast vs slow machine state (blocks pooled over offered loads, mean ± 95% CI)",
          fontsize=9.5, y=1.02)
    save(fig, "f7c_overhead_by_state")


def fig_r1():
    path = os.path.join(args.r1, "sweeps.csv")
    if not os.path.exists(path):
        print("skip R1 (no", path, ")"); return
    acc = defaultdict(lambda: [0, 0])
    for r in csv.DictReader(open(path)):
        k = (int(r["max_session_keys"]), int(r["rate_target"]), int(r["mrpc"]))
        acc[k][0] += int(r["session_reused"]); acc[k][1] += 2 * int(r["handshakes"])
    keys = sorted({k[0] for k in acc})
    fig, ax = plt.subplots(figsize=(5.4, 3.3))
    for j, rate in enumerate((100, 300, 400)):
        for m, ls, mk in ((1, "-", "o"), (2, "--", "^")):
            ys = [min(acc[(n, rate, m)][0] / acc[(n, rate, m)][1], 1.0) for n in keys]
            ax.plot(range(len(keys)), ys, color=RAMP[[0, 2, 3][j]], ls=ls, marker=mk, label=f"{rate} req/s, mrpc = {m}")
    xcat(ax, [f"{n}{' (default)' if n == 1 else ''}" for n in keys], "client max_session_keys (ticket slots)")
    ax.set_ylabel("resumed handshakes / all handshakes")
    ax.set_ylim(0.83, 1.005)
    ax.legend(frameon=False, fontsize=7, loc="lower right")
    title(ax, "Session resumption share vs client ticket cache size\n(R1, X25519MLKEM768 resumed arm, 3 repetitions pooled)", fontsize=9)
    save(fig, "f8_r1_resumption_share")


fig_cpu()
fig_overhead()
fig_handshake_cost()
fig_pq_addon_points()
fig_mtls_overhead()
fig_latency()
fig_memory()
fig_states()
fig_state_independence()
fig_overhead_by_state()
fig_r1()
fig_cpu_split()
print(f"excluded outlier blocks: {len(drop)}; blocks fast/slow: "
      f"{sum(v == 'fast' for v in STATE.values())}/{sum(v == 'slow' for v in STATE.values())}")
