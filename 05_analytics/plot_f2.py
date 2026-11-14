"""Figures for F2 (classic TLS 1.2 / 1.3 cipher suites), final campaign, English labels.

F2a = handshake per request (mrpc = 1, 200 req/s), F2b = keep-alive with 1 MB responses (100 req/s).
One run = one block with all six setups in random order; comparisons vs TLS 1.3 default are
paired inside the block, then mean and 95% t-CI over runs. Old result files (no block columns)
are also accepted: every row counts as ok and a block = (session, run).

Usage:
  .venv/bin/python -I 05_analytics/plot_f2.py [--no-titles]
      [--f2a 04_results/Final_F2a_classic_handshake] [--f2b 04_results/Final_F2b_classic_payload]
Output: <f2a dir>/plots[_latex]/  (PNG 300 dpi + PDF); a missing phase is skipped.
"""
import argparse
import csv
import os
import statistics as st
from collections import defaultdict

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

T95 = {2: 12.706, 3: 4.303, 4: 3.182, 5: 2.776, 6: 2.571, 7: 2.447, 8: 2.365, 9: 2.306, 10: 2.262}
ap = argparse.ArgumentParser()
ap.add_argument("--f2a", default="04_results/Final_F2a_classic_handshake")
ap.add_argument("--f2b", default="04_results/Final_F2b_classic_payload")
ap.add_argument("--out", default=None, help="output dir (default: <f2a>/plots or plots_latex)")
ap.add_argument("--no-titles", action="store_true")
args = ap.parse_args()
TITLES = not args.no_titles
OUT = args.out or os.path.join(args.f2a, "plots" if TITLES else "plots_latex")
os.makedirs(OUT, exist_ok=True)

BLUE, GRAY = "#2a78d6", "#7a7974"
INK, INK2, GRID_C = "#0b0b0b", "#52514e", "#e4e3df"
SETUPS = [  # setup -> axis label (TLS version, cipher suite as negotiated)
    ("plaintext", "plaintext"),
    ("mtls1.3-default", "TLS 1.3\nAES-128-GCM"),
    ("mtls1.2-gcm", "TLS 1.2\nAES-128-GCM"),
    ("mtls1.2-gcm256", "TLS 1.2\nAES-256-GCM"),
    ("mtls1.2-chacha", "TLS 1.2\nChaCha20-\nPoly1305"),
    ("mtls1.2-cbc", "TLS 1.2\nAES-128-CBC\n-SHA256"),
]
REF = "mtls1.3-default"
PHASES = [("F2a", args.f2a, "handshake per request (mrpc = 1, 200 req/s)"),
          ("F2b", args.f2b, "keep-alive, 1 MB responses (100 req/s)")]

plt.rcParams.update({
    "font.size": 9, "axes.titlesize": 9.5, "axes.labelsize": 9, "legend.fontsize": 8,
    "axes.edgecolor": INK2, "axes.labelcolor": INK, "xtick.color": INK2, "ytick.color": INK2,
    "axes.grid": True, "grid.color": GRID_C, "grid.linewidth": 0.6, "axes.axisbelow": True,
    "axes.spines.top": False, "axes.spines.right": False, "lines.markersize": 6,
    "errorbar.capsize": 3, "savefig.dpi": 300, "font.family": "DejaVu Sans",
})


def load(d):
    """-> dict block_key -> setup -> row (only accepted blocks)."""
    path = os.path.join(d, "sweeps.csv")
    if not os.path.exists(path):
        return None
    blocks = defaultdict(dict)
    for r in csv.DictReader(open(path)):
        if r.get("block_status", "ok") not in ("ok", "nogate"):
            continue
        key = r.get("block_id") or f"s{r['session']}_run{r['run']}"
        blocks[key][r["setup"]] = r
    return {k: v for k, v in blocks.items() if all(s in v for s, _ in SETUPS)}


def ci(v):
    n = len(v)
    return st.mean(v), (T95[n] * st.stdev(v) / n ** 0.5 if n > 1 else 0.0)


def iqr(v):
    q = st.quantiles(v, n=4) if len(v) > 1 else [v[0]] * 3
    return st.median(v), q[0], q[2]


def save(fig, name):
    for ext in ("png", "pdf"):
        fig.savefig(os.path.join(OUT, f"{name}.{ext}"), bbox_inches="tight")
    plt.close(fig)
    print("wrote", os.path.join(OUT, name + ".png"))


def setup_axis(ax, setups):
    ax.set_xticks(range(len(setups)))
    ax.set_xticklabels([lab for _, lab in setups], fontsize=7.5)


def panel_cpu(ax, blocks):
    for i, (s, _) in enumerate(SETUPS):
        mu, h = ci([float(b[s]["cpu_per_req_us"]) for b in blocks.values()])
        ax.errorbar([i], [mu / 1000], yerr=[h / 1000], color=GRAY if s == "plaintext" else BLUE, marker="o")
    setup_axis(ax, SETUPS)
    ax.set_ylim(bottom=0)


def panel_vs_ref(ax, blocks):
    sel = [x for x in SETUPS if x[0] not in ("plaintext", REF)]
    for i, (s, _) in enumerate(sel):
        v = [(float(b[s]["cpu_per_req_us"]) / float(b[REF]["cpu_per_req_us"]) - 1) * 100 for b in blocks.values()]
        ax.plot([i - 0.08] * len(v), v, ls="none", marker="o", ms=2.8, color=BLUE, alpha=0.45)
        mu, h = ci(v)
        ax.errorbar([i + 0.06], [mu], yerr=[h], color=BLUE, marker="D", ms=5)
    ax.axhline(0, color=INK2, lw=0.8)
    setup_axis(ax, sel)


def panel_latency(ax, blocks, key):
    for i, (s, _) in enumerate(SETUPS):
        med, q1, q3 = iqr([float(b[s][key]) for b in blocks.values()])
        ax.errorbar([i], [med], yerr=[[med - q1], [q3 - med]], color=GRAY if s == "plaintext" else BLUE, marker="o")
    setup_axis(ax, SETUPS)
    ax.set_ylim(bottom=0)


def resumed_share(blocks):
    out = []
    for s, _ in SETUPS[1:]:
        hs = sum(int(b[s]["handshakes"]) for b in blocks.values())
        ru = sum(int(b[s]["session_reused"]) for b in blocks.values())
        out.append(ru / (2 * hs) if hs else float("nan"))
    return out


data = [(n, load(d), desc) for n, d, desc in PHASES]
data = [(n, b, desc) for n, b, desc in data if b]
if not data:
    raise SystemExit("no F2 data found")
for n, b, _ in data:
    print(f"{n}: {len(b)} accepted blocks")


def two_panel(name, draw, ylabel, sup, sharey=False):
    fig, axes = plt.subplots(1, len(data), figsize=(4.6 * len(data), 3.4), sharey=sharey, squeeze=False)
    for ax, (n, blocks, desc) in zip(axes[0], data):
        draw(ax, blocks)
        ax.set_title(f"{n}: {desc}" if TITLES or len(data) > 1 else "")
        ax.set_ylabel(ylabel)
    if TITLES:
        fig.suptitle(sup, fontsize=9.5, y=1.02)
    save(fig, name)


two_panel("f2_cpu_per_request", panel_cpu, "sidecar CPU per request [ms]\n(client + server)",
          "Classic TLS: CPU cost per request (mean ± 95% CI over runs)")
two_panel("f2_cpu_vs_tls13", panel_vs_ref, "CPU per request vs TLS 1.3 AES-128-GCM [%]",
          "Classic TLS vs TLS 1.3 default, paired within block (dots = runs, diamonds = mean ± 95% CI)")
two_panel("f2_latency_p50", lambda ax, b: panel_latency(ax, b, "p50_ms"), "latency p50 [ms]",
          "Classic TLS: latency p50 (median over runs, bars = interquartile range)")
two_panel("f2_latency_p99", lambda ax, b: panel_latency(ax, b, "p99_ms"), "latency p99 [ms]",
          "Classic TLS: latency p99 (median over runs, bars = interquartile range)")

# resumed share in F2a: are the TLS 1.2 handshakes full or resumed?
for n, blocks, _ in data:
    if n == "F2a":
        sh = resumed_share(blocks)
        fig, ax = plt.subplots(figsize=(5.2, 3.0))
        ax.bar(range(len(sh)), sh, 0.6, color=BLUE, edgecolor="white")
        for i, v in enumerate(sh):
            ax.text(i, v + 0.02, f"{v:.2f}", ha="center", fontsize=8, color=INK2)
        setup_axis(ax, SETUPS[1:])
        ax.set_ylim(0, 1.1)
        ax.set_ylabel("resumed handshakes / all handshakes")
        if TITLES:
            ax.set_title("F2a: share of resumed handshakes per setup (all runs pooled)", fontsize=9)
        save(fig, "f2a_resumed_share")
