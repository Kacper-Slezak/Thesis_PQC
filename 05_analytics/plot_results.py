#!/usr/bin/env python3
"""
Figures and paired comparisons for one results directory.


"""
import argparse
import os
import sys

import matplotlib
import numpy as np
import pandas as pd

matplotlib.use("Agg")
import matplotlib.pyplot as plt

CALIB_OUTLIER = 1.5   # calibration > 1.5x the session median = disturbed window
N_BOOT = 4000
MIN_PAIRS_PLOT = 3    # comparisons with fewer pairs stay in the CSV but are not plotted

# Fixed order and colours: colour follows the setup, never its position in a plot
ORDER = ["plaintext", "mtls1.3-x25519", "mtls1.3-postquantum", "mtls1.3-x25519-full",
         "mtls1.3-postquantum-full", "mtls1.3-default", "mtls1.2-gcm", "mtls1.2-gcm256",
         "mtls1.2-chacha", "mtls1.2-cbc"]
PALETTE = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4",
           "#008300", "#6250d6", "#e34948", "#eda100", "#e87ba4"]
MARKERS = ["o", "s", "^", "D", "v", "P", "X", "*", "h", "<"]
COLOR = dict(zip(ORDER, PALETTE))
MARK = dict(zip(ORDER, MARKERS))
INK, MUTED, GRID, SURF = "#0b0b0b", "#6b6a64", "#e6e5e0", "#ffffff"

PAIRS = [
    ("mtls1.3-postquantum-full", "mtls1.3-x25519-full"),
    ("mtls1.3-postquantum",      "mtls1.3-x25519"),
    ("mtls1.3-x25519-full",      "mtls1.3-x25519"),
    ("mtls1.3-postquantum-full", "mtls1.3-postquantum"),
    ("mtls1.3-x25519",           "plaintext"),
    ("mtls1.3-x25519-full",      "plaintext"),
    ("mtls1.3-postquantum",      "plaintext"),
    ("mtls1.3-postquantum-full", "plaintext"),
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
        cpu="CPU of both sidecars per request [µs]", mrpc="requests per connection (mrpc)",
        rate="offered load [requests/s]", minutes="minutes since session start",
        dev="deviation from group median [%]", session="Session",
        p50="p50 latency [ms]", p99="p99 latency [ms]", conn="new connections per second",
        pqc="extra CPU per request,\nX25519MLKEM768 vs X25519 [%]",
        reuse="share of resumed handshakes",
        full="full handshake", resumed="resumed handshake",
        t_stab="Measurement stability: deviation of each window from its group median",
        t_box="CPU per request", t_mrpc="CPU per request vs requests per connection",
        t_pqc="Cost of hybrid post-quantum key exchange (pairs from the same block, 95% CI)",
        t_lat="Latency vs rate of new connections",
        t_rate="CPU per request vs offered load",
        t_reuse="Session resumption under load", at="at", rps="req/s"),
    "pl": dict(
        names={"plaintext": "plaintext", "mtls1.3-x25519": "X25519 wznowiony",
               "mtls1.3-postquantum": "X25519MLKEM768 wznowiony", "mtls1.3-x25519-full": "X25519 pełny",
               "mtls1.3-postquantum-full": "X25519MLKEM768 pełny", "mtls1.3-default": "TLS 1.3 domyślny",
               "mtls1.2-gcm": "TLS 1.2 AES-128-GCM", "mtls1.2-gcm256": "TLS 1.2 AES-256-GCM",
               "mtls1.2-chacha": "TLS 1.2 ChaCha20", "mtls1.2-cbc": "TLS 1.2 AES-128-CBC"},
        cpu="CPU obu sidecarów na żądanie [µs]", mrpc="żądania na połączenie (mrpc)",
        rate="obciążenie [żądania/s]", minutes="minuty od startu sesji",
        dev="odchylenie od mediany grupy [%]", session="Sesja",
        p50="opóźnienie p50 [ms]", p99="opóźnienie p99 [ms]", conn="nowe połączenia na sekundę",
        pqc="dodatkowe CPU na żądanie,\nX25519MLKEM768 vs X25519 [%]",
        reuse="udział wznowionych handshake'ów",
        full="pełny handshake", resumed="wznowiony handshake",
        t_stab="Stabilność pomiaru: odchylenie każdego okna od mediany jego grupy",
        t_box="CPU na żądanie", t_mrpc="CPU na żądanie a liczba żądań na połączenie",
        t_pqc="Koszt hybrydowej wymiany kluczy PQC (pary z tego samego bloku, 95% CI)",
        t_lat="Opóźnienie a liczba nowych połączeń",
        t_rate="CPU na żądanie a obciążenie",
        t_reuse="Wznawianie sesji pod obciążeniem", at="przy", rps="żąd./s"),
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


def setups_in(df):
    present = [s for s in ORDER if s in set(df.setup)]
    return present + sorted(set(df.setup) - set(present))


def ci(values, sessions):
    """95% CI of the mean: bootstrap over sessions when there are >= 3, else t-interval."""
    values, sessions = np.asarray(values, float), np.asarray(sessions)
    if len(values) < 2:
        return np.nan, np.nan
    uniq = np.unique(sessions)
    if len(uniq) >= 3:
        rng = np.random.default_rng(1)
        by = {s: values[sessions == s] for s in uniq}
        means = [np.concatenate([by[s] for s in rng.choice(uniq, len(uniq))]).mean() for _ in range(N_BOOT)]
        return tuple(np.percentile(means, [2.5, 97.5]))
    from scipy import stats
    h = stats.t.ppf(0.975, len(values) - 1) * values.std(ddof=1) / np.sqrt(len(values))
    return values.mean() - h, values.mean() + h


def paired_table(df):
    """Pairs = the two setups measured in the same block (session, run, rate, mrpc)."""
    rows = []
    key = ["session", "run"]
    cols = ["cpu_per_req_us", "p50_ms", "p99_ms"]
    for (rate, m), d in df.groupby(["rate_target", "mrpc"]):
        for a, b in PAIRS:
            A = d[d.setup == a].set_index(key)[cols]
            B = d[d.setup == b].set_index(key)[cols]
            j = A.join(B, lsuffix="_a", rsuffix="_b", how="inner")
            if j.empty:
                continue
            d_us = j.cpu_per_req_us_a - j.cpu_per_req_us_b
            d_pct = d_us / j.cpu_per_req_us_b * 100
            s = j.index.get_level_values("session")
            lo_us, hi_us = ci(d_us, s)
            lo_p, hi_p = ci(d_pct, s)
            rows.append(dict(rate_target=rate, mrpc=m, setup_a=a, setup_b=b, n_pairs=len(j),
                             n_sessions=len(np.unique(s)),
                             diff_us=d_us.mean(), ci_us_lo=lo_us, ci_us_hi=hi_us,
                             diff_pct=d_pct.mean(), ci_pct_lo=lo_p, ci_pct_hi=hi_p,
                             sd_pct=d_pct.std(ddof=1),
                             diff_p50_ms=(j.p50_ms_a - j.p50_ms_b).mean(),
                             diff_p99_ms=(j.p99_ms_a - j.p99_ms_b).mean()))
    return pd.DataFrame(rows)


def save(fig, out, name):
    for ext in ("png", "pdf"):
        fig.savefig(os.path.join(out, f"{name}.{ext}"), dpi=200, bbox_inches="tight")
    plt.close(fig)
    print(f"  {name}.png / .pdf")


def fig_stability(df, T, out):
    """Validation figure: how far each window lies from the median of its (setup, rate, mrpc)."""
    if "timestamp" not in df:
        return
    dev = df.cpu_per_req_us / df.groupby(["setup", "rate_target", "mrpc"]).cpu_per_req_us.transform("median") - 1
    sess = sorted(df.session.unique())
    fig, axes = plt.subplots(1, len(sess), figsize=(4 * len(sess), 3.4), sharey=True, squeeze=False)
    for ax, s in zip(axes[0], sess):
        h = df.session == s
        t = (df.timestamp[h] - df.timestamp[h].min()).dt.total_seconds() / 60
        ax.scatter(t, dev[h] * 100, s=14, color=COLOR["plaintext"], alpha=0.7, edgecolor="none", zorder=3)
        ax.axhline(0, color=MUTED, lw=0.8)
        ax.set_title(f"{T['session']} {s}")
        ax.set_xlabel(T["minutes"])
    axes[0][0].set_ylabel(T["dev"])
    fig.suptitle(T["t_stab"], x=0.01, ha="left", fontsize=11)
    fig.tight_layout(rect=(0, 0, 1, 0.93))
    save(fig, out, "stability_timeline")


def fig_boxplots(df, T, out):
    rng = np.random.default_rng(3)
    setups = setups_in(df)
    for rate, dr in df.groupby("rate_target"):
        ms = mrpc_order(dr.mrpc.unique())
        ncols = min(2, len(ms))
        nrows = int(np.ceil(len(ms) / ncols))
        w = max(3.2, 0.7 * len(setups) + 0.8)
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
                ax.scatter(k + rng.uniform(-0.17, 0.17, len(g)), g.cpu_per_req_us, s=20,
                           color=COLOR.get(s, MUTED), marker=MARK.get(s, "o"),
                           edgecolor=SURF, linewidth=0.6, zorder=3)
            ax.set_xticks(range(len(setups)))
            ax.set_xticklabels([T["names"].get(s, s) for s in setups], rotation=35, ha="right", fontsize=8)
            ax.set_title(f"mrpc = {mrpc_label(m)}")
            if idx % ncols == 0:
                ax.set_ylabel(T["cpu"])
        for idx in range(len(ms), nrows * ncols):
            axes[idx // ncols][idx % ncols].set_visible(False)
        fig.suptitle(f"{T['t_box']} ({T['at']} {rate:g} {T['rps']})", x=0.01, ha="left", fontsize=11)
        fig.tight_layout(rect=(0, 0, 1, 0.96))
        save(fig, out, f"boxplots_r{rate:g}")


def fig_cpu_vs_mrpc(df, T, out):
    if df.mrpc.nunique() < 2:
        return
    rates, setups, ms = sorted(df.rate_target.unique()), setups_in(df), mrpc_order(df.mrpc.unique())
    fig, axes = plt.subplots(1, len(rates), figsize=(3.8 * len(rates) + 1, 3.8), sharey=True, squeeze=False)
    for ax, rate in zip(axes[0], rates):
        d = df[df.rate_target == rate]
        for s in setups:
            med = d[d.setup == s].groupby("mrpc").cpu_per_req_us.median()
            xs = [j for j, m in enumerate(ms) if m in med.index]
            if xs:
                ax.plot(xs, [med[ms[j]] for j in xs], color=COLOR.get(s, MUTED), marker=MARK.get(s, "o"),
                        ms=6, mec=SURF, mew=1.5, label=T["names"].get(s, s))
        ax.set_xticks(range(len(ms)))
        ax.set_xticklabels([mrpc_label(m) for m in ms])
        ax.set_title(f"{rate:g} {T['rps']}")
        ax.set_xlabel(T["mrpc"])
    axes[0][0].set_ylabel(T["cpu"])
    axes[0][-1].legend(loc="upper right", fontsize=8)
    fig.suptitle(T["t_mrpc"], x=0.01, ha="left", fontsize=11)
    fig.tight_layout(rect=(0, 0, 1, 0.93))
    save(fig, out, "cpu_vs_mrpc")


def fig_cpu_vs_rate(df, T, out):
    if df.rate_target.nunique() < 2:
        return
    ms, setups = mrpc_order(df.mrpc.unique()), setups_in(df)
    fig, axes = plt.subplots(1, len(ms), figsize=(3.6 * len(ms) + 1, 3.8), sharey=True, squeeze=False)
    for ax, m in zip(axes[0], ms):
        d = df[df.mrpc == m]
        for s in setups:
            med = d[d.setup == s].groupby("rate_target").cpu_per_req_us.median()
            if not med.empty:
                ax.plot(med.index, med.values, color=COLOR.get(s, MUTED), marker=MARK.get(s, "o"), ms=6,
                        mec=SURF, mew=1.5, label=T["names"].get(s, s))
        ax.set_title(f"mrpc = {mrpc_label(m)}")
        ax.set_xlabel(T["rate"])
    axes[0][0].set_ylabel(T["cpu"])
    axes[0][-1].legend(loc="upper right", fontsize=8)
    fig.suptitle(T["t_rate"], x=0.01, ha="left", fontsize=11)
    fig.tight_layout(rect=(0, 0, 1, 0.93))
    save(fig, out, "cpu_vs_rate")


def fig_pqc(tab, T, out):
    series = [("mtls1.3-postquantum", "mtls1.3-x25519", T["resumed"]),
              ("mtls1.3-postquantum-full", "mtls1.3-x25519-full", T["full"])]
    if tab.empty:
        return
    keep = np.array([(a, b) in [(x, y) for x, y, _ in series] for a, b in zip(tab.setup_a, tab.setup_b)])
    t = tab[keep & (tab.n_pairs >= MIN_PAIRS_PLOT)]
    if t.empty:
        return
    rates, ms = sorted(t.rate_target.unique()), mrpc_order(t.mrpc.unique())
    fig, axes = plt.subplots(1, len(rates), figsize=(max(7.5, 3.8 * len(rates) + 1), 4), sharey=True, squeeze=False)
    for ax, rate in zip(axes[0], rates):
        for off, (a, b, lab) in zip((-0.12, 0.12), series):
            r = t[(t.rate_target == rate) & (t.setup_a == a) & (t.setup_b == b)].set_index("mrpc")
            sel = [m for m in ms if m in r.index]
            if not sel:
                continue
            xs = [ms.index(m) + off for m in sel]
            y = r.loc[sel, "diff_pct"].values
            err = np.vstack([y - r.loc[sel, "ci_pct_lo"].values, r.loc[sel, "ci_pct_hi"].values - y])
            ax.errorbar(xs, y, yerr=np.nan_to_num(err), color=COLOR[a], marker=MARK[a], ms=7, mec=SURF,
                        mew=1.5, capsize=3, lw=2, label=lab)
        ax.axhline(0, color=MUTED, lw=0.8)
        ax.set_xticks(range(len(ms)))
        ax.set_xticklabels([mrpc_label(m) for m in ms])
        ax.set_xlabel(T["mrpc"])
        ax.set_title(f"{rate:g} {T['rps']}")
    axes[0][0].set_ylabel(T["pqc"])
    h, l = axes[0][0].get_legend_handles_labels()
    fig.legend(h, l, loc="upper right", ncol=2, fontsize=9)
    fig.suptitle(T["t_pqc"], x=0.01, ha="left", fontsize=11)
    fig.tight_layout(rect=(0, 0, 1, 0.90))
    save(fig, out, "pqc_overhead")


def fig_latency(df, T, out):
    d = df[df.mrpc > 0].copy()
    if d.empty:
        return
    d["conn_per_s"] = d.window_rps / d.mrpc
    fig, axes = plt.subplots(1, 2, figsize=(11, 4.2), squeeze=False)
    for ax, col, lab in [(axes[0][0], "p50_ms", T["p50"]), (axes[0][1], "p99_ms", T["p99"])]:
        for s in setups_in(d):
            g = d[d.setup == s]
            ax.scatter(g.conn_per_s, g[col], s=22, marker=MARK.get(s, "o"), color=COLOR.get(s, MUTED),
                       edgecolor=SURF, linewidth=0.6, label=T["names"].get(s, s), zorder=3)
        ax.set_xlabel(T["conn"])
        ax.set_ylabel(lab)
    axes[0][1].set_yscale("log")
    axes[0][0].legend(fontsize=8, loc="upper left")
    fig.suptitle(T["t_lat"], x=0.01, ha="left", fontsize=11)
    fig.tight_layout(rect=(0, 0, 1, 0.93))
    save(fig, out, "latency_vs_connections")


def fig_resumption(df, T, out):
    d = df[df.setup.isin(["mtls1.3-x25519", "mtls1.3-postquantum"]) & (df.mrpc > 0) & (df.handshakes > 0)].copy()
    if d.empty or d.rate_target.nunique() < 2:
        return
    # handshakes = server side only, session_reused = client + server, hence the factor 2
    d["reuse"] = d.session_reused / (2 * d.handshakes)
    ms = mrpc_order(d.mrpc.unique())
    fig, axes = plt.subplots(1, len(ms), figsize=(3.4 * len(ms) + 1, 3.6), sharey=True, squeeze=False)
    for ax, m in zip(axes[0], ms):
        for s in ["mtls1.3-x25519", "mtls1.3-postquantum"]:
            med = d[(d.mrpc == m) & (d.setup == s)].groupby("rate_target").reuse.median()
            if not med.empty:
                ax.plot(med.index, med.values, color=COLOR[s], marker=MARK[s], ms=6, mec=SURF, mew=1.5,
                        label=T["names"][s])
        ax.set_title(f"mrpc = {mrpc_label(m)}")
        ax.set_xlabel(T["rate"])
        ax.set_ylim(0, 1.05)
    axes[0][0].set_ylabel(T["reuse"])
    axes[0][-1].legend(loc="lower left", fontsize=8)
    fig.suptitle(T["t_reuse"], x=0.01, ha="left", fontsize=11)
    fig.tight_layout(rect=(0, 0, 1, 0.92))
    save(fig, out, "resumption_vs_rate")


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
    if "session" not in df:
        df["session"] = 1

    bad = (df.fail_rate > 0) | (df.dropped_iters > 0) | ((df.setup == "plaintext") & (df.handshakes > 0))
    print(f"Dropping {bad.sum()} windows with k6 errors, dropped iterations or plaintext handshakes")
    df = df[~bad].copy()
    if "calib_ms" in df and df["calib_ms"].notna().any():
        slow = df["calib_ms"] > CALIB_OUTLIER * df.groupby("session")["calib_ms"].transform("median")
        print(f"Dropping {slow.sum()} windows whose calibration took > {CALIB_OUTLIER}x the session median")
        df = df[~slow].copy()
    print(f"Using {len(df)} windows from {df.session.nunique()} session(s)")

    out = os.path.join(args.results_dir, "plots")
    os.makedirs(out, exist_ok=True)
    style()
    T = TXT[args.lang]
    df.to_csv(os.path.join(out, "windows_used.csv"), index=False)

    tab = paired_table(df)
    tab.to_csv(os.path.join(out, "paired.csv"), index=False)
    print(f"  paired.csv ({len(tab)} comparisons)")

    fig_stability(df, T, out)
    fig_boxplots(df, T, out)
    fig_cpu_vs_mrpc(df, T, out)
    fig_cpu_vs_rate(df, T, out)
    fig_pqc(tab, T, out)
    fig_latency(df, T, out)
    fig_resumption(df, T, out)
    print(f"Figures in {out}")


if __name__ == "__main__":
    main()