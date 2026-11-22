"""Stability-gate accounting per session (methodology table), stdlib only.

Per session, from gate.csv and sweeps.csv:
  attempts   block attempts (one entry + one exit canary each)
  rejected   exit canary off by more than 5% from the entry canary -> block measured again
  accepted   blocks that passed the exit check (used in the analysis)
  entry      first = first block of a grid point in the session (becomes the reference),
             ok = entry canary within 5% of that reference, shifted = outside (machine in the
             other state; the block is still measured because pairs are compared inside it)
  session gate: tries until 5 canaries agree (CV <= 3%), CV of the accepted try
  calib_ms: median host calibration of the accepted windows (turbo off ~400 ms)

Usage: .venv/bin/python -I 05_analytics/gate_table.py [04_results/Final_grid]
Output: printed (Markdown) and <grid>/gate_table.{md,csv,tex}
"""
import csv
import os
import statistics as st
import sys
from collections import defaultdict

GRID = sys.argv[1] if len(sys.argv) > 1 else "04_results/Final_grid"
gate = list(csv.DictReader(open(os.path.join(GRID, "gate.csv"))))
rows = list(csv.DictReader(open(os.path.join(GRID, "sweeps.csv"))))

S = defaultdict(lambda: defaultdict(int))
for r in gate:
    s, ph, res = r["session"], r["phase"], r["result"].split()[0]
    if ph == "exit":
        S[s]["attempts"] += 1
        S[s]["rejected" if res == "fail" else "accepted"] += 1
    elif ph == "enter":
        S[s][f"entry_{res}"] += 1
    elif ph == "session" and res in ("pass", "wait", "timeout"):
        S[s]["gate_tries"] += 1
        if res == "pass":
            S[s]["gate_cv"] = float(r["result"].split("cv=")[1])
dates = defaultdict(list)
calib = defaultdict(list)
for r in rows:
    if r["block_status"] == "ok":
        dates[r["session"]].append(r["timestamp"][:10])
        calib[r["session"]].append(float(r["calib_ms"]))

cols = ["session", "dates", "attempts", "rejected", "rejected %", "accepted",
        "entry first", "entry ok", "entry shifted", "gate tries", "gate CV %", "calib ms"]
table = []
for s in sorted(S, key=int):
    d = S[s]
    ds = sorted(set(dates[s]))
    table.append([s, ds[0][5:] if len(ds) == 1 else f"{ds[0][5:]}..{ds[-1][5:]}", d["attempts"], d["rejected"],
                  f"{100 * d['rejected'] / d['attempts']:.0f}", d["accepted"], d["entry_first"], d["entry_ok"],
                  d["entry_shifted"], d["gate_tries"], f"{d['gate_cv']:.2f}", f"{st.median(calib[s]):.0f}"])
tot = [sum(int(r[i]) for r in table) for i in (2, 3, 5, 6, 7, 8, 9)]
table.append(["total", "", tot[0], tot[1], f"{100 * tot[1] / tot[0]:.0f}", tot[2], tot[3], tot[4], tot[5], tot[6], "",
              f"{st.median(c for v in calib.values() for c in v):.0f}"])

note = ("Session 5 re-measured 4 blocks that replace blocks of sessions 1-3 (state flip inside the block, "
        "missed by the exit canary), so 112 of the 116 accepted blocks enter the analysis (8 per grid point). "
        "Session 2 has two session gates because its first attempt was interrupted by a kubectl exec failure.")
md = ["| " + " | ".join(cols) + " |", "|" + "---|" * len(cols)]
md += ["| " + " | ".join(str(x) for x in r) + " |" for r in table]
text = "\n".join(md) + "\n\n" + note + "\n"
print(text)
open(os.path.join(GRID, "gate_table.md"), "w").write(text)
with open(os.path.join(GRID, "gate_table.csv"), "w", newline="") as f:
    w = csv.writer(f, lineterminator="\n")
    w.writerow(cols)
    w.writerows(table)
tex = ["\\begin{tabular}{l l r r r r r r r r r r}", "\\hline",
       " & ".join(c.replace("%", "\\%") for c in cols) + " \\\\", "\\hline"]
tex += [" & ".join(str(x).replace("%", "\\%") for x in r) + " \\\\" for r in table[:-1]]
tex += ["\\hline", " & ".join(str(x) for x in table[-1]) + " \\\\", "\\hline", "\\end{tabular}"]
open(os.path.join(GRID, "gate_table.tex"), "w").write("\n".join(tex) + "\n")
