# Docuemntation of script setuping cluster

## Descirption of the specific code lines and the sources:

1. `set -eo pipefail` - `-e` ends the script when the scirpt get error `-o` staus of the pipe is the status of first commend
2. `k3d cluster create thesis-cluster` - create a cluster with specific flags:
   - `--agents` - worker nodes number
   - `--api-port` - port where the host is listening
   - `--k3s-arg "--disable=traefik@server:0"` - disable traefik due to using istio 
   - `k3s-arg "--kubelet-arg-allowed-unsafe-sysctls=net.ipv4.tcp_tw_reuse:*"` - allowed unsafe due to test in k6
   - Sources: 
     - https://k3d.io/stable/usage/commands/k3d_cluster_create/#synopsis
     - https://docs.k3s.io/cli/server
     - https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/
3. `docker ps` - flag `-q` return only ID 
4. `wget` - `-S` sever response `-T 10` timeout 
5. `mapfile -t` map the ordered nodes and check if it is less then 2
6.  `docker update` - pinning the node container to choosen processor cores 
7. Prometheus config - change interval and timeout
``` bash
kubectl get configmap prometheus -n istio-system -o yaml \
  | sed -e 's/scrape_interval: .*/scrape_interval: 5s/' \
        -e 's/scrape_timeout: .*/scrape_timeout: 4s/' \
  | kubectl apply -f -


kubectl rollout restart deployment prometheus -n istio-system
```
8. Check rollout is waiting 240 sec for pods to be ready and running if not is checking diagnostic
``` bash
check_rollout() {
  local deploy=$1 app=$2
  if ! kubectl rollout status "deployment/$deploy" -n default --timeout=240s; then
    echo "Deploy rollout timed out. Diagnostics"
    kubectl get pods -n default -l "app=$app" -o wide
    kubectl describe pods -n default -l "app=$app" | tail -40
    exit 1
  fi
}
```
9. `./01_scripts/record_env.sh` - start script which save env to txt 