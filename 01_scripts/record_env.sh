#!/bin/bash
# This script records the environment information to a file for reproducibility and debugging purposes.

OUT="${1:-./04_results/Summary/environment.txt}"
mkdir -p "$(dirname "$OUT")"

{
  echo "date:            $(date -u +%FT%TZ)"
  echo "git_commit:      $(git describe --always --dirty)"
  echo "kernel:          $(uname -r)"
  echo "cpu_model:       $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
  echo "cpu_threads:     $(nproc)"
  echo "aes_ni:          $(grep -qm1 -w aes /proc/cpuinfo && echo yes || echo no)"
  echo "avx2:            $(grep -qm1 -w avx2 /proc/cpuinfo && echo yes || echo no)"
  echo "ram:             $(free -h | awk '/Mem:/{print $2}')"
  echo "docker:          $(docker version --format '{{.Server.Version}}')"
  echo "k3d:             $(k3d version | head -1)"
  echo "istioctl:        $(istioctl version --remote=false)"
  echo "istio_requested: ${ISTIO_VERSION:-$(grep -m1 '^ISTIO_VERSION=' ./01_scripts/setup_cluster.sh | cut -d'"' -f2)}"
  echo "istiod_image:    $(kubectl get deploy istiod -n istio-system -o jsonpath='{.spec.template.spec.containers[0].image}')"
  echo "envoy:           $(kubectl exec deploy/httpbin -c istio-proxy -- pilot-agent request GET server_info | grep -m1 '"version"' | tr -d ' ,')"
  echo "backend_image:   $(kubectl get deploy httpbin -o jsonpath='{.spec.template.spec.containers[0].image}')"
  echo "k6:              $(kubectl exec deploy/k6-deploy -c k6 -- k6 version | head -1)"
} > "$OUT"

echo "Saved to $OUT"
