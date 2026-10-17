#!/usr/bin/env python3
"""
Statistical analysis script for sweeps.csv benchmark results.

Usage:
  python3 05_analytics/analyze_stats.py [mode]
"""
import sys

import pandas as pd
from scipy import stats

DIR = "./04_results/Summary"
MODE = sys.argv[1] if len(sys.argv) > 1 else "handshake"

# Metrics to analyze
METRICS = ["cpu_per_req_us", "window_rps", "p50_ms", "p99_ms"]

# Pairs to compare: (A, B) calculates relative diff (A - B) / B
PAIRS = [
    ("mtls1.3-x25519",           "plaintext"),             # mTLS baseline vs plaintext
    ("mtls1.3-x25519-full",      "plaintext"),             # full handshake vs plaintext
    ("mtls1.3-x25519-full",      "mtls1.3-x25519"),        # full handshake vs resumed
    ("mtls1.3-postquantum-full", "mtls1.3-x25519-full"),   # PQC vs classical X25519
]


def mean_ci(values):
    """Mean and 95% confidence interval using Student's t-distribution."""
    n = len(values)
    mean = values.mean()
    if n < 2:
        return mean, float("nan"), float("nan")
    sem = values.std(ddof=1) / (n ** 0.5)
    t = stats.t.ppf(0.975, df=n - 1)
    return mean, mean - t * sem, mean + t * sem


# Load sweep data
df = pd.read_csv(f"{DIR}/sweeps.csv")
df = df[df["mode"] == MODE]
if df.empty:
    sys.exit(f"No rows with mode={MODE} in sweeps.csv")

# Group points by target rate and requests per connection
POINT = ["rate_target", "mrpc"]

report = [f"# Statistical report (mode = {MODE})", ""]
results = []

for point, d in df.groupby(POINT):
    report += [f"## Point: rate={point[0]}/s, mrpc={point[1]}", ""]

    # 1. Summary stats per setup
    for metric in METRICS:
        report += [f"### {metric}", "",
                   "| setup | n | mean | std | 95% CI |",
                   "|---|---|---|---|---|"]
        for setup, g in d.groupby("setup"):
            v = g[metric].dropna()
            mean, lo, hi = mean_ci(v)
            report.append(f"| {setup} | {len(v)} | {mean:.1f} | {v.std(ddof=1):.1f} | [{lo:.1f}, {hi:.1f}] |")
        report.append("")

    # 2. Pairwise comparisons
    report += ["### Pairwise comparisons (paired t-test on same session and run)", "",
               "| metric | A | B | pairs | diff A vs B | 95% CI | p-value | per session |",
               "|---|---|---|---|---|---|---|---|"]
    for a, b in PAIRS:
        da = d[d["setup"] == a].set_index(["session", "run"])
        db = d[d["setup"] == b].set_index(["session", "run"])
        if da.empty or db.empty:
            continue
        for metric in METRICS:
            # Match pairs by (session, run)
            pairs = pd.concat([da[metric].rename("A"), db[metric].rename("B")], axis=1, join="inner").dropna()
            if len(pairs) < 2:
                continue
            diff_pct = (pairs["A"] - pairs["B"]) / pairs["B"] * 100
            mean, lo, hi = mean_ci(diff_pct)
            p = stats.ttest_1samp(diff_pct, 0).pvalue
            per_session = diff_pct.groupby(level="session").mean()
            sess_txt = ", ".join(f"S{s}: {x:+.1f}%" for s, x in per_session.items())

            report.append(f"| {metric} | {a} | {b} | {len(pairs)} | {mean:+.1f}% | "
                          f"[{lo:+.1f}, {hi:+.1f}] | {p:.3g} | {sess_txt} |")
            results.append(dict(mode=MODE, rate_target=point[0], mrpc=point[1], metric=metric,
                                setup_a=a, setup_b=b, n_pairs=len(pairs), diff_pct=mean,
                                ci_lo=lo, ci_hi=hi, p_value=p, per_session=sess_txt))
    report.append("")

# 3. TLS session resumption
# session_reused is summed from both sidecars, so divide by 2
report += ["## TLS session resumption", "",
           "| setup | handshakes | reused | reused share | conn errors |",
           "|---|---|---|---|---|"]
for setup, g in df[df["setup"] != "plaintext"].groupby("setup"):
    hs, reused, err = g["handshakes"].sum(), g["session_reused"].sum(), g["conn_errors"].sum()
    share = reused / 2 / hs * 100 if hs else 0
    report.append(f"| {setup} | {hs:.0f} | {reused:.0f} | {share:.1f}% | {err:.0f} |")
report.append("")

# 4. Key exchange verification
try:
    ev = pd.read_csv(f"{DIR}/curve_evidence.csv")
    report += ["## Key exchange verification (curve_evidence.csv)", "",
               "| setup | windows | PASS | FAIL |", "|---|---|---|---|"]
    for setup, g in ev.groupby("setup"):
        report.append(f"| {setup} | {len(g)} | {(g.verdict == 'PASS').sum()} | {(g.verdict == 'FAIL').sum()} |")
    report.append("")
except FileNotFoundError:
    report += ["_curve_evidence.csv not found_", ""]

# Save report and results
open(f"{DIR}/stats_report.md", "w").write("\n".join(report))
pd.DataFrame(results).to_csv(f"{DIR}/stats_results.csv", index=False)
print(f"Saved {DIR}/stats_report.md and {DIR}/stats_results.csv")
