#!/usr/bin/env python3
"""
Memory of the Envoy sidecars vs number of concurrent connections (campaign M1).

Input : <dir>/memory.csv written by run_memory.sh (one row = one sample of both sidecars)
Output: <dir>/plots/memory_vs_connections.png|pdf  and  <dir>/plots/memory_slopes.csv

Two ways of reading the memory of a sidecar are plotted (rows of the figure):
  Envoy allocated  - bytes the Envoy allocator hands out (curl localhost:15000/memory, "allocated")
  cgroup current   - memory.current of the istio-proxy container (Envoy + runtime + page cache)
For both, a straight line memory = base + slope * connections is fitted per setup.
The slope [KiB per connection] is the number quoted in the thesis. The x axis is the number of
ESTABLISHED TCP connections counted in /proc/net/tcp (client_conns / server_conns), not the
target of the load test.

Usage:
  python3 05_analytics/plot_memory.py 04_results/M1_memory_20261028_1650 --lang pl

Caveat: the 3 samples taken at one level are 15 s apart, so they are not independent and the
confidence intervals of the slopes are optimistic. Report the slopes of both runs as well.
"""
import argparse
import os
import sys

import matplotlib
import numpy as np
import pandas as pd
from scipy import stats

matplotlib.use("Agg")
import matplotlib.pyplot as plt

# Colours and markers follow the setup, as in plot_results.py
COLOR = {"plaintext": "#2a78d6", "mtls1.3-x25519": "#eb6834", "mtls1.3-postquantum": "#1baf7a"}
MARK = {"plaintext": "o", "mtls1.3-x25519": "s", "mtls1.3-postquantum": "^"}
INK, MUTED, GRID, SURF = "#0b0b0b", "#6b6a64", "#e6e5e0", "#ffffff"
MIB, KIB = 2 ** 20, 2 ** 10

TXT = {
    "en": dict(names={"plaintext": "plaintext", "mtls1.3-x25519": "mTLS X25519",
                      "mtls1.3-postquantum": "mTLS X25519MLKEM768"},
               conns="established connections", mem="memory [MiB]",
               envoy="Envoy allocated memory", cg="cgroup memory.current",
               client="client sidecar", server="server sidecar",
               title="Sidecar memory vs concurrent connections (straight-line fit per setup)", per="KiB/conn"),
    "pl": dict(names={"plaintext": "plaintext", "mtls1.3-x25519": "mTLS X25519",
                      "mtls1.3-postquantum": "mTLS X25519MLKEM768"},
               conns="nawiązane połączenia", mem="pamięć [MiB]",
               envoy="pamięć przydzielona przez Envoya", cg="cgroup memory.current",
               client="sidecar klienta", server="sidecar serwera",
               title="Pamięć sidecarów a liczba równoczesnych połączeń (prosta dopasowana osobno do każdego setupu)",
               per="KiB/poł."),
}
MEASURES = [("envoy", "envoy_alloc_b"), ("cg", "cg_current_b")]
SIDES = [("client", "client_conns"), ("server", "server_conns")]


def style():
    plt.rcParams.update({
        "font.size": 10, "axes.edgecolor": MUTED, "axes.labelcolor": INK, "text.color": INK,
        "xtick.color": MUTED, "ytick.color": MUTED, "axes.spines.top": False,
        "axes.spines.right": False, "figure.facecolor": SURF, "axes.facecolor": SURF,
        "axes.grid": True, "axes.grid.axis": "y", "grid.color": GRID, "grid.linewidth": 0.8,
        "axes.titlelocation": "left", "axes.titlesize": 10, "legend.frameon": False,
        "lines.linewidth": 2,
    })


def fit(x, y):
    """Straight-line fit: slope in KiB per connection (+-95% CI), base in MiB, R^2."""
    r = stats.linregress(x, y)
    half = stats.t.ppf(0.975, len(x) - 2) * r.stderr
    return r.slope / KIB, half / KIB, r.intercept / MIB, r.rvalue ** 2


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("results_dir")
    ap.add_argument("--lang", choices=["en", "pl"], default="en")
    args = ap.parse_args()

    path = os.path.join(args.results_dir, "memory.csv")
    if not os.path.exists(path):
        sys.exit(f"No {path}")
    df = pd.read_csv(path)

    bad = df.k6_fail_rate.fillna(0) > 0
    if bad.any():
        print(f"Dropping {bad.sum()} samples taken while k6 reported failed requests")
        df = df[~bad]
    for side, col in SIDES:   # the real number of connections should match the target
        off = (df[col] - df.conns_target).abs() > 0.05 * df.conns_target.clip(lower=1)
        if off.any():
            print(f"Warning: {off.sum()} samples have a {side} connection count more than 5% off the target")

    out = os.path.join(args.results_dir, "plots")
    os.makedirs(out, exist_ok=True)
    style()
    T = TXT[args.lang]
    setups = [s for s in COLOR if s in set(df.setup)] + sorted(set(df.setup) - set(COLOR))

    fig, axes = plt.subplots(len(MEASURES), len(SIDES), figsize=(10.5, 7), sharex="col", sharey="row", squeeze=False)
    # top of every row = 8% above the largest value of that row (both sidecars), so nothing is cut off
    top = {mkey: 1.08 * max(df[f"{side}_{mcol}"].max() for side, _ in SIDES) / MIB for mkey, mcol in MEASURES}
    rows = []
    for i, (mkey, mcol) in enumerate(MEASURES):
        for j, (side, xcol) in enumerate(SIDES):
            ax = axes[i][j]
            for s in setups:
                g = df[df.setup == s]
                x, y = g[xcol].to_numpy(float), g[f"{side}_{mcol}"].to_numpy(float)
                slope, half, base, r2 = fit(x, y)
                xs = np.array([0, x.max()])
                c, mk = COLOR.get(s, MUTED), MARK.get(s, "o")
                ax.scatter(x, y / MIB, s=16, color=c, marker=mk, edgecolor=SURF, linewidth=0.5, alpha=0.85, zorder=3)
                ax.plot(xs, (base * MIB + slope * KIB * xs) / MIB, color=c, lw=1.6,
                        label=f"{T['names'].get(s, s)}: {slope:.1f} {T['per']}")
                rows.append(dict(setup=s, side=side, measure=mcol, slope_kib_per_conn=slope, ci95_kib=half,
                                 base_mib=base, r2=r2, n=len(g)))
                for run, gr in g.groupby("run"):   # slope of every run separately (consistency check)
                    sl = fit(gr[xcol].to_numpy(float), gr[f"{side}_{mcol}"].to_numpy(float))[0]
                    rows.append(dict(setup=s, side=side, measure=mcol, run=run, slope_kib_per_conn=sl,
                                     n=len(gr)))
            ax.set_title(f"{T['client'] if side == 'client' else T['server']}, {T[mkey]}")
            ax.legend(fontsize=8, loc="upper left")
            if j == 0:
                ax.set_ylabel(T["mem"])
            if i == len(MEASURES) - 1:
                ax.set_xlabel(T["conns"])
            ax.set_ylim(0, top[mkey])
    fig.suptitle(T["title"], x=0.01, ha="left", fontsize=11)
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    for ext in ("png", "pdf"):
        fig.savefig(os.path.join(out, f"memory_vs_connections.{ext}"), dpi=200, bbox_inches="tight")
    plt.close(fig)

    tab = pd.DataFrame(rows)
    tab.to_csv(os.path.join(out, "memory_slopes.csv"), index=False)
    print(f"  memory_vs_connections.png / .pdf, memory_slopes.csv in {out}")
    show = tab[tab.run.isna()].drop(columns="run")
    print(show.round(3).to_string(index=False))


if __name__ == "__main__":
    main()
