"""Time-series figures for the live demo (run_live.sh): Prometheus data with phase boundaries.

Usage: .venv/bin/python -I 05_analytics/plot_live.py 04_results/Live_<stamp> [--no-titles]
Output: <dir>/plots[_latex]/live_timeline.(png|pdf) and one file per panel.
"""
import argparse
import csv
import json
import os

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument("dir")
ap.add_argument("--no-titles", action="store_true")
args = ap.parse_args()
TITLES = not args.no_titles
OUT = os.path.join(args.dir, "plots" if TITLES else "plots_latex")
os.makedirs(OUT, exist_ok=True)

BLUE, ORANGE, GRAY = "#2a78d6", "#eb6834", "#7a7974"
INK, INK2, GRID_C, SHADE = "#0b0b0b", "#52514e", "#e4e3df", "#f1f0ec"
LABEL = {"plaintext": "plaintext", "mtls1.3-x25519-full": "X25519\nfull", "mtls1.3-postquantum-full": "X25519MLKEM768\nfull",
         "mtls1.3-x25519": "X25519\nresumed", "mtls1.3-postquantum": "X25519MLKEM768\nresumed"}
plt.rcParams.update({
    "font.size": 9, "axes.labelsize": 9, "legend.fontsize": 8, "axes.edgecolor": INK2, "axes.labelcolor": INK,
    "xtick.color": INK2, "ytick.color": INK2, "axes.grid": True, "grid.color": GRID_C, "grid.linewidth": 0.6,
    "axes.axisbelow": True, "axes.spines.top": False, "axes.spines.right": False, "lines.linewidth": 1.6,
    "savefig.dpi": 300, "font.family": "DejaVu Sans",
})

phases = list(csv.DictReader(open(os.path.join(args.dir, "phases.csv"))))
T0 = float(phases[0]["start_unix"])


def series(name):
    """-> list of (label, xs [min since first phase], ys) from prom_<name>.json; [] if missing/empty."""
    p = os.path.join(args.dir, f"prom_{name}.json")
    if not os.path.exists(p):
        return []
    d = json.load(open(p))
    out = []
    for r in d.get("data", {}).get("result", []):
        xs = [(float(t) - T0) / 60 for t, _ in r["values"]]
        ys = [float(v) if v not in ("NaN", "+Inf") else float("nan") for _, v in r["values"]]
        out.append((r["metric"], xs, ys))
    return out


def shade(ax, top_labels=False):
    for i, ph in enumerate(phases):
        a, b = (float(ph["start_unix"]) - T0) / 60, (float(ph["end_unix"]) - T0) / 60
        if i % 2 == 0:
            ax.axvspan(a, b, color=SHADE, lw=0, zorder=0)
        ax.axvline(a, color=INK2, lw=0.6, ls=":")
        if top_labels:
            ax.text((a + b) / 2, 1.02, LABEL.get(ph["setup"], ph["setup"]), transform=ax.get_xaxis_transform(),
                    ha="center", va="bottom", fontsize=7, color=INK2)


def pod_style(metric):
    pod = metric.get("pod", "")
    return ("server sidecar (httpbin)", ORANGE) if pod.startswith("httpbin") else ("client sidecar (k6)", BLUE)


def draw_cpu(ax):
    for m, xs, ys in series("cpu"):
        lab, c = pod_style(m)
        ax.plot(xs, [y * 1000 for y in ys], color=c, label=lab)
    ax.set_ylabel("sidecar CPU [millicores]")


def draw_memory(ax):
    for m, xs, ys in series("memory"):
        lab, c = pod_style(m)
        ax.plot(xs, [y / 2**20 for y in ys], color=c, label=lab)
    ax.set_ylabel("sidecar memory\n(working set) [MiB]")


def draw_handshakes(ax):
    for name, lab, c, ls in (("handshakes", "handshakes / s (server)", BLUE, "-"), ("reused", "resumed / s (server)", BLUE, "--")):
        for _, xs, ys in series(name):
            ax.plot(xs, ys, color=c, ls=ls, label=lab)
    for m, xs, ys in series("curves"):
        nm = m.get("__name__", "").split("curves_")[-1]
        if "MLKEM" in nm:
            ax.plot(xs, ys, color=ORANGE, ls=":", lw=2.2, label=f"key exchange {nm} / s")
    ax.set_ylabel("TLS handshakes / s")


def draw_latency(ax):
    for name, lab, ls in (("p50", "p50", "-"), ("p99", "p99", "--")):
        for _, xs, ys in series(name):
            ax.plot(xs, ys, color=BLUE, ls=ls, label=f"latency {lab}")
    ax.set_ylabel("request latency [ms]\n(Istio telemetry)")


def draw_rps(ax):
    for _, xs, ys in series("rps"):
        ax.plot(xs, ys, color=GRAY, label="requests / s")
    ax.set_ylabel("requests / s")


PANELS = [("cpu", draw_cpu), ("handshakes", draw_handshakes), ("latency", draw_latency), ("memory", draw_memory), ("rps", draw_rps)]
PANELS = [(n, f) for n, f in PANELS if any(series(k) for k in {"cpu": ["cpu"], "handshakes": ["handshakes"], "latency": ["p50", "p99"],
                                                                  "memory": ["memory"], "rps": ["rps"]}[n])]

fig, axes = plt.subplots(len(PANELS), 1, figsize=(9, 1.9 * len(PANELS)), sharex=True)
for k, (ax, (n, draw)) in enumerate(zip(axes, PANELS)):
    shade(ax, top_labels=(k == 0))
    draw(ax)
    ax.legend(frameon=False, loc="upper left", bbox_to_anchor=(1.01, 1), fontsize=7)
    ax.set_ylim(bottom=0)
axes[-1].set_xlabel("time since the first phase [min]")
if TITLES:
    fig.suptitle(f"Live run with monitoring on: configuration switched every phase (Prometheus, 5 s scrape)",
                 fontsize=9.5, y=1.0)
fig.align_ylabels(axes)
for ext in ("png", "pdf"):
    fig.savefig(os.path.join(OUT, f"live_timeline.{ext}"), bbox_inches="tight")
plt.close(fig)
print("wrote", os.path.join(OUT, "live_timeline.png"))

for n, draw in PANELS:
    fig, ax = plt.subplots(figsize=(9, 2.4))
    shade(ax, top_labels=True)
    draw(ax)
    ax.legend(frameon=False, loc="upper left", bbox_to_anchor=(1.01, 1), fontsize=7)
    ax.set_ylim(bottom=0)
    ax.set_xlabel("time since the first phase [min]")
    for ext in ("png", "pdf"):
        fig.savefig(os.path.join(OUT, f"live_{n}.{ext}"), bbox_inches="tight")
    plt.close(fig)
    print("wrote", os.path.join(OUT, f"live_{n}.png"))
