#!/usr/bin/env bash
# f4_run_all.sh – cały prototyp F4 jednym poleceniem, po kolei:
#   cluster -> versions -> pki -> deploy -> smoke all -> sdscheck -> bench
# Uruchamiaj z katalogu głównego repo (obok f4_proto.sh i f4_pki.sh w 01_scripts/):
#   ./01_scripts/f4_run_all.sh
# Bezpieczniej na długo (bench to ok. 1-1,5 h; log i tak zapisuje się do pliku):
#   nohup ./01_scripts/f4_run_all.sh > /dev/null 2>&1 &   potem:  tail -f 04_results/F4_proto/run_all_*.log
#
# Zmienne:
#   YES=1          nie pytaj o potwierdzenie kasowania klastra
#   SKIP_CLUSTER=1 klaster na Istio 1.31.4 już stoi (np. po wcześniejszym przebiegu); pomija krok 'cluster'
#   REGEN_PKI=1    wygeneruj certyfikaty od nowa (domyślnie: jeśli ./f4_pki już jest, użyj go)
#   SKIP_SDSCHECK=1 pomiń opcjonalny dowód z pilot-agentem
#   SKIP_BENCH=1   zatrzymaj się po smoke (sam test dymny, ok. 15-20 min po klastrze)
#   FORCE=1        uruchom bench nawet jeśli smoke zgłosił FAIL (domyślnie: stop, bo pomiary byłyby bezwartościowe)
#   ARMS, RATES, MRPCS, N_RUNS, DURATION, QUIET – przekazywane do bench (patrz f4_proto.sh)
set -o pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 1
P=./01_scripts/f4_proto.sh
OUT=${OUT:-04_results/F4_proto}
mkdir -p "$OUT"
LOG="$OUT/run_all_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1

T_ALL=$(date +%s)
log()  { echo; echo "######## $(date '+%F %T')  $*"; }
fail() { echo; echo "!!!!!!!! $*"; echo "Log: $LOG"; exit 1; }

step() {   # step <nazwa> <polecenie...>   – zatrzymuje cały przebieg przy błędzie
  local name=$1 t0 rc; shift
  log "KROK: $name"
  t0=$(date +%s)
  "$@"; rc=$?
  echo "-------- $name: koniec po $(( $(date +%s) - t0 )) s, kod=$rc"
  [ "$rc" -eq 0 ] || fail "krok '$name' nie powiódł się (kod $rc). Pliki do wgrania: $OUT/ (w tym ten log)."
}

# ------------------------------------------------------------ sprawdzenie środowiska
log "SPRAWDZENIE ŚRODOWISKA"
need="docker kubectl istioctl jq python3 bc shuf"
[ "${SKIP_CLUSTER:-0}" = 1 ] || need="$need k3d"
for c in $need; do
  command -v "$c" >/dev/null 2>&1 || fail "brak polecenia '$c' w PATH"
done
for f in "$P" ./01_scripts/f4_pki.sh ./01_scripts/lib_setups.sh ./02_manifests/peerauthentication_plaintext.yaml ./03_test_scripts/main_k6_scenarios.js; do
  [ -f "$f" ] || fail "brak pliku $f (uruchamiasz z katalogu głównego repo? skrypty f4_* są w 01_scripts/?)"
done
IST=$(istioctl version --remote=false 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
[ "$IST" = "${ISTIO_TARGET:-1.31.4}" ] || fail "istioctl to '$IST', a potrzebny ${ISTIO_TARGET:-1.31.4}
  curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.31.4 TARGET_ARCH=x86_64 sh -
  export PATH=\$PWD/istio-1.31.4/bin:\$PATH"
docker info >/dev/null 2>&1 || fail "docker nie odpowiada (WSL: uruchom Docker Desktop / daemon)"
echo "OK: narzędzia są, istioctl $IST, docker działa."

if [ "${SKIP_CLUSTER:-0}" != 1 ] && [ "${YES:-0}" != 1 ]; then
  echo
  echo "Ten przebieg:"
  echo "  1. KASUJE klaster 'thesis-cluster' i zakłada nowy na Istio $IST (ok. 10-15 min),"
  echo "  2. generuje certyfikaty, wdraża je, robi test dymny (ok. 15-20 min),"
  echo "  3. uruchamia wstępną kampanię F4 (ok. 1-1,5 h, o ile nie SKIP_BENCH=1)."
  read -r -p "Kontynuować? [t/N] " a
  [[ "$a" =~ ^[tTyY] ]] || fail "przerwano"
fi
export YES=1

# ------------------------------------------------------------ kroki
if [ "${SKIP_CLUSTER:-0}" = 1 ]; then log "KROK: cluster – pominięty (SKIP_CLUSTER=1)"; else step cluster bash "$P" cluster; fi
step versions bash "$P" versions

if [ -f ./f4_pki/mldsa/server.key ] && [ -f ./f4_pki/rsa/server.key ] && [ -f ./f4_pki/ecdsa/server.key ] && [ "${REGEN_PKI:-0}" != 1 ]; then
  log "KROK: pki – pominięty, ./f4_pki już istnieje (REGEN_PKI=1 wygeneruje od nowa)"
else
  step pki bash "$P" pki
fi
step deploy bash "$P" deploy

SMOKE_OK=1
log "KROK: smoke all"
bash "$P" smoke all || SMOKE_OK=0
if [ "$SMOKE_OK" -eq 1 ]; then
  echo "-------- smoke: wszystkie ramiona PASS"
else
  echo "-------- smoke: są FAIL-e (szczegóły: $OUT/smoke_*.txt)"
fi

if [ "${SKIP_SDSCHECK:-0}" != 1 ]; then
  log "KROK: sdscheck (opcjonalny, błąd nie zatrzymuje)"
  bash "$P" sdscheck || echo "(sdscheck zakończony błędem – pomijam)"
fi

if [ "${SKIP_BENCH:-0}" = 1 ]; then
  log "KROK: bench – pominięty (SKIP_BENCH=1)"
elif [ "$SMOKE_OK" -ne 1 ] && [ "${FORCE:-0}" != 1 ]; then
  log "KROK: bench – NIE uruchamiam, bo smoke zgłosił FAIL"
  echo "Wgraj mi pliki z $OUT/ (smoke_*.txt, sdscheck.txt, versions.txt, ten log) – poprawię konfigurację."
  echo "Jeśli mimo to chcesz pomiary: FORCE=1 SKIP_CLUSTER=1 ./01_scripts/f4_run_all.sh"
  exit 2
else
  step bench bash "$P" bench
fi

# ------------------------------------------------------------ podsumowanie
log "PODSUMOWANIE (łącznie $(( ($(date +%s) - T_ALL) / 60 )) min)"
if [ -f "$OUT/sweeps.csv" ]; then
  echo "sweeps.csv: $(( $(wc -l < "$OUT/sweeps.csv") - 1 )) okien; werdykty:"
  awk -F, 'NR>1 {split($NF,v,":"); c[v[1]]++} END {for (k in c) print "  " k ": " c[k]}' "$OUT/sweeps.csv"
fi
echo "Pliki do wgrania do rozmowy: $OUT/ (smoke_*.txt, sdscheck.txt, versions.txt, deploy_mounts_*.txt, sweeps.csv, $(basename "$LOG"))"
[ "$SMOKE_OK" -eq 1 ]