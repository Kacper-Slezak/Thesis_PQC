"""Robustness checks for the final grid (appendix tables), stdlib only.

Each check answers "would the conclusion change if the analysis were done differently?":
  1. Sessions instead of runs: the 8 runs are 4 sessions x 2 runs on the same cluster and day,
     so they are not fully independent. Average the 2 runs of a session first, then the 95% CI
     comes from 4 values (t = 3.182) instead of 8 (t = 2.365).
  2. Original vs re-measured blocks: 4 blocks (machine state flipped inside the block) were
     measured again in session 5 (replacements.csv). Same table with the original blocks.
  3. Machine-state threshold: blocks are called fast/slow by their entry canary relative to the
     lowest level of the same grid point (threshold 9%, chosen after looking at the data). Repeat
     the split for other thresholds and compare the post-quantum overhead in both states.

Usage: .venv/bin/python -I 05_analytics/robustness.py [04_results/Final_grid]
Output: printed and written to <grid>/robustness.txt
"""
import csv
import io
import os
import statistics as st
import sys
from collections import defaultdict
from contextlib import redirect_stdout

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from final_summary import PQ, PQF, T95, X, XF, ci, label, load, points  # noqa: E402

GRID = sys.argv[1] if len(sys.argv) > 1 else "04_results/Final_grid"
PAIRS = {"PQ full vs X25519 full": (PQF, XF), "PQ resumed vs X resumed": (PQ, X)}


def pct(b, a, ref):
    return (float(b[a]["cpu_per_req_us"]) / float(b[ref]["cpu_per_req_us"]) - 1) * 100


def fmt(m, h, n):
    return f"{m:+5.1f} ±{h:4.1f} (n={n})"


def check_sessions(blocks):
    print("## 1. Runs (n = 8, t = 2.365) vs sessions (2 runs averaged per session, n = 4, t = 3.182)")
    print("Post-quantum overhead, change in CPU per request [%], mean ± 95% CI")
    print(f"{'point':>8} | " + " | ".join(f"{p + ' / runs':>30} | {'sessions':>18}" for p in PAIRS))
    worst = {p: 0.0 for p in PAIRS}
    for pt in points(blocks):
        cells = []
        for p, (a, b) in PAIRS.items():
            ks = [k for k in blocks if k[2:] == pt]
            runs = [pct(blocks[k], a, b) for k in ks]
            by_s = defaultdict(list)
            for k in ks:
                by_s[k[0]].append(pct(blocks[k], a, b))
            sess = [st.mean(v) for v in by_s.values()]
            (mr, hr), (ms, hs) = ci(runs), ci(sess)
            worst[p] = max(worst[p], hs / hr if hr else 0)
            cells.append(f"{fmt(mr, hr, len(runs)):>30} | {fmt(ms, hs, len(sess)):>18}")
        print(f"{label(pt):>8} | " + " | ".join(cells))
    print("CI width sessions / runs, largest ratio: " + ", ".join(f"{p}: {r:.2f}x" for p, r in worst.items()))
    print()


def check_replacements(new, old):
    print("## 2. Re-measured blocks (session 5) vs the original blocks they replace")
    rep = list(csv.DictReader(open(os.path.join(GRID, "replacements.csv"))))
    keys = [(m["orig_session"], m["orig_run"], int(m["rate"]), int(m["mrpc"])) for m in rep]
    print("Single blocks, post-quantum overhead [%]:")
    for k in keys:
        cells = [f"{p}: {pct(old[k], a, b):+6.1f} -> {pct(new[k], a, b):+6.1f}" for p, (a, b) in PAIRS.items()]
        print(f"  s{k[0]} run{k[1]} {label(k[2:]):>8}  " + "   ".join(cells))
    print("Grid points containing a replaced block, mean ± 95% CI over 8 runs:")
    print(f"{'point':>8} | " + " | ".join(f"{p + ' / original':>32} | {'re-measured':>18}" for p in PAIRS))
    for pt in sorted({k[2:] for k in keys}, key=lambda p: (p[1] == 0, p[1], p[0])):
        cells = []
        for p, (a, b) in PAIRS.items():
            o = [pct(old[k], a, b) for k in old if k[2:] == pt]
            n = [pct(new[k], a, b) for k in new if k[2:] == pt]
            cells.append(f"{fmt(*ci(o), len(o)):>32} | {fmt(*ci(n), len(n)):>18}")
        print(f"{label(pt):>8} | " + " | ".join(cells))
    print("All other grid points use identical blocks in both versions.")
    print()


def check_threshold(blocks):
    print("## 3. Machine-state threshold: entry canary vs lowest canary of the same (rate, mrpc)")
    gate = [r for r in csv.DictReader(open(os.path.join(GRID, "gate.csv"))) if r["phase"] in ("enter", "exit")]
    lo = defaultdict(lambda: float("inf"))
    for r in gate:
        lo[(r["rate"], r["mrpc"])] = min(lo[(r["rate"], r["mrpc"])], float(r["cpu_per_req_us"]))
    level = {r["block_id"]: (float(r["cpu_per_req_us"]) / lo[(r["rate"], r["mrpc"])] - 1) * 100
             for r in gate if r["phase"] == "enter"}
    lv = sorted(level[b[XF]["block_id"]] for b in blocks.values())
    gap = max((b - a, a, b) for a, b in zip(lv, lv[1:]))
    print(f"Entry-canary levels of the 112 used blocks: {lv[0]:.1f}..{lv[-1]:.1f}%; "
          f"largest empty gap {gap[1]:.1f}%..{gap[2]:.1f}% (any threshold inside it gives the same split)")
    print("Post-quantum overhead by state, blocks pooled over offered loads, mean ± 95% CI [%]:")
    for thr in (6, 9, 12):
        fast = {k for k, b in blocks.items() if level[b[XF]["block_id"]] < thr}
        print(f"  threshold {thr:>2}%: fast {len(fast):>3} / slow {len(blocks) - len(fast):>3} blocks")
        for p, (a, b) in PAIRS.items():
            cells = []
            for m in (1, 2, 5, 0):
                out = []
                for nm, sel in (("fast", True), ("slow", False)):
                    v = [pct(blocks[k], a, b) for k in blocks if k[3] == m and (k in fast) == sel]
                    if len(v) >= 2:
                        mu = st.mean(v)
                        h = (T95[len(v)] if len(v) in T95 else 1.96) * st.stdev(v) / len(v) ** 0.5
                        out.append(f"{nm} {mu:+.1f}±{h:.1f}")
                    else:
                        out.append(f"{nm} n={len(v)}")
                cells.append(f"mrpc {m if m else 'inf'}: " + ", ".join(out))
            print(f"    {p:>24}: " + " | ".join(cells))
    print()


def main():
    _, new = load(GRID)
    _, old = load(GRID, replace=False)
    buf = io.StringIO()
    with redirect_stdout(buf):
        print(f"# Robustness checks ({GRID})\n")
        check_sessions(new)
        check_replacements(new, old)
        check_threshold(new)
    text = buf.getvalue()
    print(text, end="")
    with open(os.path.join(GRID, "robustness.txt"), "w") as fh:
        fh.write(text)


if __name__ == "__main__":
    main()
