"""Schematic timeline of one measurement window (one setup inside a block), from the code:
apply_setup sleeps 15 s, apply_dr 10 s, warmup() runs k6 at 50 req/s for 20 s then SETTLE_S = 20 s,
the test runs 60 s (WARM_S = 10, STEADY_S = 45, COOL_S = 5), then COOLDOWN_S = 10 s.

Usage: .venv/bin/python -I 05_analytics/plot_window_timeline.py [--no-titles]
Output: docs/figures/window_timeline.(png|pdf)
"""
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

TITLES = "--no-titles" not in sys.argv
BLUE, ORANGE, GRAY, LIGHT = "#2a78d6", "#eb6834", "#7a7974", "#e4e3df"
INK, INK2 = "#0b0b0b", "#52514e"
plt.rcParams.update({"font.size": 9, "font.family": "DejaVu Sans", "savefig.dpi": 300})

# (start, length, label, colour, text colour)
segs = [(0, 15, "apply\nsetup", LIGHT, INK),
        (15, 10, "DR\n(mrpc)", LIGHT, INK),
        (25, 20, "warm-up\nk6 50 req/s", LIGHT, INK),
        (45, 20, "settle", LIGHT, INK),
        (65, 10, "test\nwarm-up", "#b7d3f6", INK),
        (75, 45, "measurement window (45 s)\nCPU, Envoy counters, memory", BLUE, "white"),
        (120, 5, "", "#b7d3f6", INK),
        (125, 10, "pause", LIGHT, INK)]

fig, ax = plt.subplots(figsize=(9.2, 2.6))
for x0, w, lab, c, tc in segs:
    ax.barh(0, w, left=x0, height=0.5, color=c, edgecolor="white", linewidth=1.5)
    ax.text(x0 + w / 2, 0, lab, ha="center", va="center", fontsize=7 if w < 20 else 8.5, color=tc)

# k6 test at the target rate: 65..125 s
ax.annotate("", xy=(65, 0.48), xytext=(125, 0.48), arrowprops=dict(arrowstyle="<->", color=INK2, lw=1))
ax.text(95, 0.56, "k6 test at the target rate (60 s): latency p50/p95/p99 over the whole 60 s",
        ha="center", va="bottom", fontsize=8, color=INK2)
# snapshots at window start and end
for x, lab in ((75, "start snapshot\nmemory → CPU, counters"), (120, "end snapshot\nCPU, counters → memory")):
    ax.plot([x, x], [-0.32, 0.27], color=ORANGE, lw=2)
    ax.text(x, -0.36, lab, ha="center", va="top", fontsize=7.5, color=ORANGE)
ax.annotate("cool-down 5 s", xy=(122.5, 0.25), xytext=(131.5, 0.38), fontsize=7, color=INK2, ha="center", va="center",
            arrowprops=dict(arrowstyle="-", color=INK2, lw=0.7))
ax.annotate("", xy=(0, -0.95), xytext=(65, -0.95), arrowprops=dict(arrowstyle="<->", color=GRAY, lw=1))
ax.text(32.5, -1.02, "configuration change (EnvoyFilter / PeerAuthentication, DestinationRule), not measured", ha="center", va="top", fontsize=7.5, color=GRAY)

ax.set_xlim(-2, 137)
ax.set_ylim(-1.25, 0.85)
ax.set_yticks([])
ax.set_xticks(range(0, 136, 15))
ax.set_xlabel("time from the start of one setup inside a block [s]")
for s in ("left", "right", "top"):
    ax.spines[s].set_visible(False)
if TITLES:
    ax.set_title("One measurement window (repeated for each of the 5 setups in a block, ~135 s each)",
                 fontsize=9.5, color=INK, pad=14)
for ext in ("png", "pdf"):
    fig.savefig(f"docs/figures/window_timeline.{ext}", bbox_inches="tight")
print("wrote docs/figures/window_timeline.png/.pdf")
