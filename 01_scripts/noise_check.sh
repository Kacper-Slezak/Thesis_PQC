set -eo pipefail
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

SETUP="${SETUP:-plaintext}"
RATE="${RATE:-200}"
N="${N:-5}"
DURATION="${DURATION:-60s}"
COOLDOWN_S="${COOLDOWN_S:-10}"

CSV=./04_results/Summary/sweeps.csv
OUTDIR=./04_results/Noise; mkdir -p "$OUTDIR"
TS=$(date +%Y%m%d_%H%M%S)
OUT="$OUTDIR/noise_${SETUP}_r${RATE}_${TS}.csv"

# Keep the main sweeps.csv clean: back it up, run, cut out the new rows, restore.
BACKUP=""
if [ -f "$CSV" ]; then BACKUP=$(mktemp); cp "$CSV" "$BACKUP"; fi
restore() { if [ -n "$BACKUP" ]; then cp "$BACKUP" "$CSV"; rm -f "$BACKUP"; else rm -f "$CSV"; fi; }
trap restore EXIT

SESSION="noise_$TS" N_RUNS="$N" DURATION="$DURATION" COOLDOWN_S="$COOLDOWN_S" RATES="$RATE" \
  ./run_sweeps.sh handshake "$SETUP"

head -1 "$CSV" > "$OUT"
grep ",noise_${TS}\$" "$CSV" >> "$OUT" || true
echo "Rows saved to $OUT"

awk -F, '
  NR==1 { for (i = 1; i <= NF; i++) col[$i] = i; next }
  {
    n++
    split("window_rps cpu_per_req_us client_sidecar_cpu server_sidecar_cpu p50_ms p99_ms", m, " ")
    for (k in m) { v = $(col[m[k]]); s[m[k]] += v; ss[m[k]] += v * v }
  }
  END {
    if (n < 2) { print "Not enough rows."; exit }
    printf "\n%-20s %10s %10s %8s   (n=%d)\n", "metric", "mean", "sd", "CV%", n
    split("window_rps cpu_per_req_us client_sidecar_cpu server_sidecar_cpu p50_ms p99_ms", m, " ")
    for (i = 1; i <= 6; i++) {
      k = m[i]; mean = s[k] / n; var = (ss[k] - n * mean * mean) / (n - 1); if (var < 0) var = 0
      sd = sqrt(var); printf "%-20s %10.3f %10.3f %7.1f%%\n", k, mean, sd, (mean ? 100 * sd / mean : 0)
    }
    print "\nRule of thumb: detecting an effect of E% with paired runs needs roughly 8-16 * (CV/E)^2 pairs."
  }' "$OUT"
