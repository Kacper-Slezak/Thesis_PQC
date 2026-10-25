#!/usr/bin/env python3
"""
Figures and machine-state-aware comparisons for one results directory.

Usage:
  python3 05_analytics/plot_results.py <results_dir> [--lang en|pl]

Reads  <results_dir>/sweeps.csv
Writes <results_dir>/plots/*.png (for Word / preview) and *.pdf (vector, for LaTeX)
       <results_dir>/plots/paired_same_state.csv (numbers behind the comparisons)
       <results_dir>/plots/windows_with_state.csv (every window with its state)

Machine state ("fast" / "slow"):
  The laptop switches between two states that change CPU per request of every setup
  by ~25% at the same time. Comparisons are therefore made only between windows
  measured in the same state (stratification, not outlier removal).
  - If sweeps.csv has a calib_ms column (fixed-work benchmark run before every window),
    the state comes from that independent measurement.
  - Otherwise (or if the calibration shows no two states) it is estimated per group (setup, rate, mrpc) by splitting CPU per request
    into two clusters; a split smaller than MIN_RATIO counts as one state.
"""
import argparse
import os
import sys

import matplotlib
import numpy as np
import pandas as pd

matplotlib.use("Agg")
import matplotlib.pyplot as plt

MIN_RATIO = 1.10      # two clusters closer than 10% are treated as one state
N_BOOT = 4000

# Fixed order and colours: colour follows the setup, never its position in a plot
ORDER = ["plaintext", "mtls1.3-x25519", "mtls1.3-postquantum", "mtls1.3-x25519-full",
         "mtls1.3-postquantum-full", "mtls1.3-default", "mtls1.2-gcm", "mtls1.2-gcm256",
         "mtls1.2-chacha", "mtls1.2-cbc"]
PALETTE = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4",
           "#008300", "#6250d6", "#e34948", "#eda100", "#e87ba4"]
MARKERS = ["o", "s", "^", "D", "v", "P", "X", "*", "h", "<"]
COLOR = dict(zip(ORDER, PALETTE))
MARK = dict(zip(ORDER, MARKERS))
FAST, SLOW = "#2a78d6", "#eb6834"
INK, MUTED, GRID, SURF = "#0b0b0b", "#6b6a64", "#e6e5e0", "#ffffff"

PAIRS = [
    ("mtls1.3-postquantum-full", "mtls1.3-x25519-full"),
    ("mtls1.3-postquantum",      "mtls1.3-x25519"),
    ("mtls1.3-x25519-full",      "mtls1.3-x25519"),
    ("mtls1.3-postquantum-full", "mtls1.3-postquantum"),
    ("mtls1.3-x25519",           "plaintext"),
    ("mtls1.3-x25519-full",      "plaintext"),
    ("mtls1.3-default",          "plaintext"),
    ("mtls1.2-gcm",              "mtls1.3-default"),
    ("mtls1.2-gcm256",           "mtls1.3-default"),
    ("mtls1.2-chacha",           "mtls1.3-default"),
    ("mtls1.2-cbc",              "mtls1.3-default"),
]

TXT = {
    "en": dict(
        names={"plaintext": "plaintext", "mtls1.3-x25519": "X25519 resumed",
               "mtls1.3-postquantum": "X25519MLKEM768 resumed", "mtls1.3-x25519-full": "X25519 full",
               "mtls1.3-postquantum-full": "X25519MLKEM768 full", "mtls1.3-default": "TLS 1.3 default",
               "mtls1.2-gcm": "TLS 1.2 AES-128-GCM", "mtls1.2-gcm256": "TLS 1.2 AES-256-GCM",
               "mtls1.2-chacha": "TLS 1.2 ChaCha20", "mtls1.2-cbc": "TLS 1.2 AES-128-CBC"},
        fast="fast state", slow="slow state", one="single state",
        cpu="CPU of both sidecars per request [µs]", mrpc="requests per connection (mrpc)",
        rate="offered load [requests/s]", minutes="minutes since session start",
        dev="deviation from group median [%]", session="Session",
        p50="median latency p50 [ms]", conn="new connections per second",
        pqc="extra CPU, X25519MLKEM768 vs X25519\n[µs per request]",
        full="full handshake", resumed="resumed handshake",
        t_states="Machine state over time: all setups shift together",
        t_box="CPU per request, colour = machine state", t_mrpc="CPU per request vs requests per connection",
        t_pqc="Cost of hybrid post-quantum key exchange (pairs from the same state, 95% CI)",
        t_lat="Latency vs rate of new connections (filled = fast state, hollow = slow)",
        t_rate="CPU per request vs offered load", at="at", rps="req/s"),
    "pl": dict(
        names={"plaintext": "plaintext", "mtls1.3-x25519": "X25519 wznowiony",
               "mtls1.3-postquantum": "X25519MLKEM768 wznowiony", "mtls1.3-x25519-full": "X25519 pełny",
               "mtls1.3-postquantum-full": "X25519MLKEM768 pełny", "mtls1.3-default": "TLS 1.3 domyślny",
               "mtls1.2-gcm": "TLS 1.2 AES-128-GCM", "mtls1.2-gcm256": "TLS 1.2 AES-256-GCM",
               "mtls1.2-chacha": "TLS 1.2 ChaCha20", "mtls1.2-cbc": "TLS 1.2 AES-128-CBC"},
        fast="stan szybki", slow="stan wolny", one="jeden stan",
        cpu="CPU obu sidecarów na żądanie [µs]", mrpc="żądania na połączenie (mrpc)",
        rate="obciążenie [żądania/s]", minutes="minuty od startu sesji",
        dev="odchylenie od mediany grupy [%]", session="Sesja",
        p50="mediana opóźnienia p50 [ms]", conn="nowe połączenia na sekundę",
        pqc="dodatkowe CPU, X25519MLKEM768 vs X25519\n[µs na żądanie]",
        full="pełny handshake", resumed="wznowiony handshake",
        t_states="Stan maszyny w czasie: wszystkie setupy przesuwają się razem",
        t_box="CPU na żądanie, kolor = stan maszyny", t_mrpc="CPU na żądanie a liczba żądań na połączenie",
        t_pqc="Koszt hybrydowej wymiany kluczy PQC (pary z tego samego stanu, 95% CI)",
        t_lat="Opóźnienie a liczba nowych połączeń (pełne = stan szybki, puste = wolny)",
        t_rate="CPU na żądanie a obciążenie", at="przy", rps="żąd./s"),
}


def style():
    plt.rcParams.update({
        "font.size": 10, "axes.edgecolor": MUTED, "axes.labelcolor": INK, "text.color": INK,
        "xtick.color": MUTED, "ytick.color": MUTED, "axes.spines.top": False,
        "axes.spines.right": False, "figure.facecolor": SURF, "axes.facecolor": SURF,
        "axes.grid": True, "axes.grid.axis": "y", "grid.color": GRID, "grid.linewidth": 0.8,
        "axes.titlelocation": "left", "axes.titlesize": 10, "legend.frameon": False,
        "lines.linewidth": 2, "lines.solid_capstyle": "round",
    })


def mrpc_label(m):
    return "∞" if m == 0 else str(int(m))


def mrpc_order(values):
    return sorted(values, key=lambda m: np.inf if m == 0 else m)


def two_means(x):
    """Split values into two clusters on a log scale. Returns (labels, ratio high/low)."""
    v = np.log(np.asarray(x, dtype=float))
    if len(v) < 4 or np.ptp(v) == 0:
        return np.zeros(len(v), dtype=int), 1.0
    c = np.array([v.min(), v.max()])
    for _ in range(100):
        lab = np.abs(v[:, None] - c[None, :]).argmin(1)
        if lab.min() == lab.max():
            break
        c = np.array([v[lab == k].mean() for k in (0, 1)])
    if lab.min() == lab.max():
        return np.zeros(len(v), dtype=int), 1.0
    return lab, float(np.exp(c[1] - c[0]))


def classify(df):
    calib_ratio = None
    if "calib_ms" in df and df["calib_ms"].notna().all():
        lab, calib_ratio = two_means(df["calib_ms"])
    if calib_ratio is not None and calib_ratio >= MIN_RATIO:
        df["slow"] = lab
        source = f"calibration benchmark (clusters {calib_ratio:.2f}x apart)"
    else:
        if calib_ratio is not None:
            print(f"Calibration shows no two states ({calib_ratio:.2f}x), falling back to CPU split")
        df["slow"] = 0
        ratios = []
        for _, g in df.groupby(["setup", "rate_target", "mrpc"]):
            lab, ratio = two_means(g["cpu_per_req_us"])
            ratios.append(ratio)
            if ratio >= MIN_RATIO:
                df.loc[g.index, "slow"] = lab
        source = f"post-hoc split of CPU per request (median split {np.median(ratios):.2f}x)"
    df["slow"] = df["slow"].astype(int)
    df["rel_dev"] = df["cpu_per_req_us"] / df.groupby(["setup", "rate_target", "mrpc"])["cpu_per_req_us"].transform("median") - 1
    return source


def ci(values, sessions):
    """95% CI of the mean: bootstrap over sessions when there are >= 2, else t-interval."""
    values, sessions = np.asarray(values, float), np.asarray(sessions)
    if len(values) < 2:
        return np.nan, np.nan
    uniq = np.unique(sessions)
    if len(uniq) >= 2:
        rng = np.random.default_rng(1)
        by = {s: values[sessions == s] for s in uniq}
        means = [np.concatenate([by[s] for s in rng.choice(uniq, len(uniq))]).mean() for _ in range(N_BOOT)]
        return tuple(np.percentile(means, [2.5, 97.5]))
    from scipy import stats
    h = stats.t.ppf(0.975, len(values) - 1) * values.std(ddof=1) / np.sqrt(len(values))
    return values.mean() - h, values.mean() + h


def paired_table(df):
    rows = []
    key = ["session", "run"]
    for (rate, m), d in df.groupby(["rate_target", "mrpc"]):
        for a, b in PAIRS:
            A = d[d.setup == a].set_index(key)[["cpu_per_req_us", "p50_ms", "slow"]]
            B = d[d.setup == b].set_index(key)[["cpu_per_req_us", "p50_ms", "slow"]]
            j = A.join(B, lsuffix="_a", rsuffix="_b", how="inner")
            if j.empty:
                continue
            same = j[j.slow_a == j.slow_b]
            d_us = same.cpu_per_req_us_a - same.cpu_per_req_us_b
            d_pct = d_us / same.cpu_per_req_us_b * 100
            d_lat = same.p50_ms_a - same.p50_ms_b
            s = same.index.get_level_values("session")
            lo_us, hi_us = ci(d_us, s)
            lo_p, hi_p = ci(d_pct, s)
            all_pct = (j.cpu_per_req_us_a - j.cpu_per_req_us_b) / j.cpu_per_req_us_b * 100
            rows.append(dict(rate_target=rate, mrpc=m, setup_a=a, setup_b=b,
                             n_pairs=len(j), n_same_state=len(same),
                             diff_us=d_us.mean(), ci_us_lo=lo_us, ci_us_hi=hi_us,
                             diff_pct=d_pct.mean(), ci_pct_lo=lo_p, ci_pct_hi=hi_p,
                             sd_pct_same_state=d_pct.std(ddof=1), diff_p50_ms=d_lat.mean(),
                             diff_pct_all_pairs=all_pct.mean(), sd_pct_all_pairs=all_pct.std(ddof=1)))
    return pd.DataFrame(rows)


def save(fig, out, name):
    for ext in ("png", "pdf"):
        fig.savefig(os.path.join(out, f"{name}.{ext}"), dpi=200, bbox_inches="tight")
    plt.close(fig)
    print(f"  {name}.png / .pdf")


def setups_in(df):
    present = [s for s in ORDER if s in set(df.setup)]
    return present + sorted(set(df.setup) - set(present))


def fig_states(df, T, out):
    if "timestamp" not in df:
        return
    sess = sorted(df.session.unique())
    fig, axes = plt.subplots(1, len(sess), figsize=(4 * len(sess), 3.4), sharey=True, squeeze=False)
    for ax, s in zip(axes[0], sess):
        g = df[df.session == s].sort_values("timestamp")
        t = (g.timestamp - g.timestamp.min()).dt.total_seconds() / 60
        one = df.slow.nunique() == 1
        for st, c, mk, lab in [(0, FAST, "o", T["one"] if one else T["fast"]), (1, SLOW, "^", T["slow"])]:
            h = g.slow == st
            if h.any():
                ax.scatter(t[h], g.rel_dev[h] * 100, s=22, color=c, marker=mk, edgecolor=SURF, linewidth=0.6, label=lab, zorder=3)
        ax.axhline(0, color=MUTED, lw=0.8)
        ax.set_title(f"{T['session']} {s}")
        ax.set_xlabel(T["minutes"])
    axes[0][0].set_ylabel(T["dev"])
    axes[0][0].legend(loc="lower left", fontsize=9)
    fig.suptitle(T["t_states"], x=0.01, ha="left", fontsize=11)
    save(fig, out, "states_timeline")


def fig_boxplots(df, T, out):
    rng = np.random.default_rng(3)
    setups = setups_in(df)
    for rate, dr in df.groupby("rate_target"):
        ms = mrpc_order(dr.mrpc.unique())
        ncols = min(3, len(ms))
        nrows = int(np.ceil(len(ms) / ncols))
        w = max(3.2, 0.75 * len(setups) + 0.8)
        fig, axes = plt.subplots(nrows, ncols, figsize=(w * ncols, 3.9 * nrows), squeeze=False)
        for idx, m in enumerate(ms):
            ax = axes[idx // ncols][idx % ncols]
            d = dr[dr.mrpc == m]
            for k, s in enumerate(setups):
                g = d[d.setup == s]
                if g.empty:
                    continue
                ax.boxplot(g.cpu_per_req_us, positions=[k], widths=0.55, showfliers=False,
                           boxprops=dict(color=MUTED), whiskerprops=dict(color=MUTED),
                           capprops=dict(color=MUTED), medianprops=dict(color=INK))
                for st, c, mk in [(0, FAST, "o"), (1, SLOW, "^")]:
                    h = g[g.slow == st]
                    ax.scatter(k + rng.uniform(-0.17, 0.17, len(h)), h.cpu_per_req_us, s=22, color=c,
                               marker=mk, edgecolor=SURF, linewidth=0.6, zorder=3)
            ax.set_xticks(range(len(setups)))
            ax.set_xticklabels([T["names"].get(s, s) for s in setups], rotation=35, ha="right", fontsize=8)
            ax.set_title(f"mrpc = {mrpc_label(m)}")
            if idx % ncols == 0:
                ax.set_ylabel(T["cpu"])
        for idx in range(len(ms), nrows * ncols):
            axes[idx // ncols][idx % ncols].set_visible(False)
        one = dr.slow.nunique() == 1
        handles = [plt.Line2D([], [], marker="o", ls="", color=FAST, label=T["one"] if one else T["fast"])]
        if not one:
            handles.append(plt.Line2D([], [], marker="^", ls="", color=SLOW, label=T["slow"]))
        fig.legend(handles=handles, loc="upper right", ncol=2, fontsize=9, bbox_to_anchor=(1.0, 1.0))
        fig.suptitle(f"{T['t_box']} ({T['at']} {rate:g} {T['rps']})", x=0.01, ha="left", fontsize=11)
        fig.tight_layout(rect=(0, 0, 1, 0.95))
        save(fig, out, f"boxplots_r{rate:g}")


def state_rows(df):
    return [st for st in (0, 1) if (df.slow == st).any()]


def state_name(T, st, n_states):
    return T["one"] if n_states == 1 else (T["fast"] if st == 0 else T["slow"])


def fig_cpu_vs_mrpc(df, T, out):
    if df.mrpc.nunique() < 2:
        return
    rates, sts, setups = sorted(df.rate_target.unique()), state_rows(df), setups_in(df)
    ms = mrpc_order(df.mrpc.unique())
    fig, axes = plt.subplots(len(sts), len(rates), figsize=(4.2 * len(rates) + 1, 3.4 * len(sts)),
                             sharex=True, sharey=True, squeeze=False)
    for i, st in enumerate(sts):
        for k, rate in enumerate(rates):
            ax = axes[i][k]
            d = df[(df.slow == st) & (df.rate_target == rate)]
            for s in setups:
                med = d[d.setup == s].groupby("mrpc").cpu_per_req_us.median()
                xs = [j for j, m in enumerate(ms) if m in med.index]
                ys = [med[m] for m in ms if m in med.index]
                if xs:
                    ax.plot(xs, ys, color=COLOR.get(s, MUTED), marker=MARK.get(s, "o"), ms=6,
                            mec=SURF, mew=1.5, label=T["names"].get(s, s))
            ax.set_xticks(range(len(ms)))
            ax.set_xticklabels([mrpc_label(m) for m in ms])
            ax.set_title(f"{state_name(T, st, len(sts))}, {rate:g} {T['rps']}")
            if i == len(sts) - 1:
                ax.set_xlabel(T["mrpc"])
        axes[i][0].set_ylabel(T["cpu"])
    axes[0][-1].legend(loc="upper right", fontsize=8)
    fig.suptitle(T["t_mrpc"], x=0.01, ha="left", fontsize=11)
    save(fig, out, "cpu_vs_mrpc")


def fig_cpu_vs_rate(df, T, out):
    if df.rate_target.nunique() < 2:
        return
    ms, sts, setups = mrpc_order(df.mrpc.unique()), state_rows(df), setups_in(df)
    fig, axes = plt.subplots(len(sts), len(ms), figsize=(3.6 * len(ms) + 1, 3.4 * len(sts)),
                             sharex=True, sharey=True, squeeze=False)
    for i, st in enumerate(sts):
        for k, m in enumerate(ms):
            ax = axes[i][k]
            d = df[(df.slow == st) & (df.mrpc == m)]
            for s in setups:
                med = d[d.setup == s].groupby("rate_target").cpu_per_req_us.median()
                if not med.empty:
                    ax.plot(med.index, med.values, color=COLOR.get(s, MUTED), marker=MARK.get(s, "o"), ms=6,
                            mec=SURF, mew=1.5, label=T["names"].get(s, s))
            ax.set_title(f"{state_name(T, st, len(sts))}, mrpc = {mrpc_label(m)}")
            if i == len(sts) - 1:
                ax.set_xlabel(T["rate"])
        axes[i][0].set_ylabel(T["cpu"])
    axes[0][-1].legend(loc="upper right", fontsize=8)
    fig.suptitle(T["t_rate"], x=0.01, ha="left", fontsize=11)
    save(fig, out, "cpu_vs_rate")


def fig_pqc(tab, T, out):
    series = [("mtls1.3-postquantum", "mtls1.3-x25519", T["resumed"]),
              ("mtls1.3-postquantum-full", "mtls1.3-x25519-full", T["full"])]
    t = tab[[(a, b) in [(x, y) for x, y, _ in series] for a, b in zip(tab.setup_a, tab.setup_b)]]
    if t.empty:
        return
    rates = sorted(t.rate_target.unique())
    ms = mrpc_order(t.mrpc.unique())
    fig, axes = plt.subplots(1, len(rates), figsize=(max(7.5, 4.2 * len(rates) + 1), 4), sharey=True, squeeze=False)
    for ax, rate in zip(axes[0], rates):
        for off, (a, b, lab) in zip((-0.12, 0.12), series):
            r = t[(t.rate_target == rate) & (t.setup_a == a) & (t.setup_b == b)].set_index("mrpc")
            xs = [j + off for j, m in enumerate(ms) if m in r.index]
            sel = [m for m in ms if m in r.index]
            if not sel:
                continue
            y = r.loc[sel, "diff_us"].values
            err = np.vstack([y - r.loc[sel, "ci_us_lo"].values, r.loc[sel, "ci_us_hi"].values - y])
            ax.errorbar(xs, y, yerr=np.nan_to_num(err), color=COLOR[a], marker=MARK[a], ms=7, mec=SURF, mew=1.5,
                        capsize=3, lw=2, label=lab)
        ax.axhline(0, color=MUTED, lw=0.8)
        ax.set_xticks(range(len(ms)))
        ax.set_xticklabels([mrpc_label(m) for m in ms])
        ax.set_xlabel(T["mrpc"])
        ax.set_title(f"{rate:g} {T['rps']}")
    axes[0][0].set_ylabel(T["pqc"])
    axes[0][-1].legend(loc="upper right", fontsize=9)
    fig.suptitle(T["t_pqc"], x=0.01, y=1.03, ha="left", fontsize=11)
    save(fig, out, "pqc_overhead")


def fig_latency(df, T, out):
    d = df.copy()
    d["conn_per_s"] = np.where(d.mrpc == 0, 0.0, d.window_rps / d.mrpc.replace(0, np.nan))
    if d.mrpc.nunique() < 2 and d.rate_target.nunique() < 2:
        return
    fig, ax = plt.subplots(figsize=(7, 4.2))
    for s in setups_in(d):
        g = d[d.setup == s]
        for st in (0, 1):
            h = g[g.slow == st]
            if h.empty:
                continue
            ax.scatter(h.conn_per_s, h.p50_ms, s=26, marker=MARK.get(s, "o"),
                       color=COLOR.get(s, MUTED) if st == 0 else SURF,
                       edgecolor=COLOR.get(s, MUTED), linewidth=1.2,
                       label=T["names"].get(s, s) if st == 0 or (g.slow == 0).sum() == 0 else None, zorder=3)
    ax.set_xlabel(T["conn"])
    ax.set_ylabel(T["p50"])
    ax.legend(fontsize=8, loc="upper left")
    ax.set_title(T["t_lat"])
    save(fig, out, "latency_vs_connections")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("results_dir")
    ap.add_argument("--lang", choices=["en", "pl"], default="en")
    args = ap.parse_args()

    path = os.path.join(args.results_dir, "sweeps.csv")
    if not os.path.exists(path):
        sys.exit(f"No {path}")
    df = pd.read_csv(path)
    if "timestamp" in df:
        try:
            df["timestamp"] = pd.to_datetime(df["timestamp"], format="ISO8601")
        except (TypeError, ValueError):
            df["timestamp"] = pd.to_datetime(df["timestamp"])
    bad = (df.fail_rate > 0) | (df.dropped_iters > 0) | ((df.setup == "plaintext") & (df.handshakes > 0))
    if bad.any():
        print(f"Dropping {bad.sum()} windows with k6 errors, dropped iterations or plaintext handshakes")
    df = df[~bad].copy()

    out = os.path.join(args.results_dir, "plots")
    os.makedirs(out, exist_ok=True)
    style()
    T = TXT[args.lang]

    source = classify(df)
    print(f"Machine state from {source}: {int(df.slow.sum())} of {len(df)} windows slow")
    df.to_csv(os.path.join(out, "windows_with_state.csv"), index=False)

    tab = paired_table(df)
    tab.to_csv(os.path.join(out, "paired_same_state.csv"), index=False)
    print(f"  paired_same_state.csv ({len(tab)} comparisons)")

    fig_states(df, T, out)
    fig_boxplots(df, T, out)
    fig_cpu_vs_mrpc(df, T, out)
    fig_cpu_vs_rate(df, T, out)
    fig_pqc(tab, T, out)
    fig_latency(df, T, out)
    print(f"Figures in {out}")


if __name__ == "__main__":
    main()
