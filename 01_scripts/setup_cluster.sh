#! /bin/bash

set -eo pipefail

ISTIO_VERSION="1.30.2"

AGENTS="2"
CLIENT_CPUSET="0,1"
SERVER_CPUSET="2,3"

export ISTIO_VERSION K6_IMAGE BACKEND_IMAGE AGENTS

echo "Delete old cluster if it exists"
k3d cluster delete thesis-cluster || true

echo "Create new cluster 'thesis-cluster'"
k3d cluster create thesis-cluster \
    --agents $AGENTS \
    --api-port 6550 \
    --k3s-arg "--disable=traefik@server:0" \
    --wait \
    --k3s-arg "--kubelet-arg=allowed-unsafe-sysctls=net.ipv4.tcp_tw_reuse@agent:*"

echo "Configuring kubernets api endpoint"
kubectl config set-cluster k3d-thesis-cluster --server=https://localhost:6550

echo "Check if cluster is ready"
kubectl get nodes

echo "Checking docker hub reachability"
NODE_CONTAINER=$(docker ps -q -f name=k3d-thesis-cluster-server-0)
if [ -z "$NODE_CONTAINER" ]; then
    echo "Node container not found"
    exit 1
fi

if docker exec "$NODE_CONTAINER" sh -c "wget -S -T 10 -O /dev/null https://registry-1.docker.io/v2/ 2>&1 | grep -q 'HTTP/'"; then
    echo "Docker Hub is reachable from the node container"
else
    echo "Docker Hub is not reachable from the node container"
fi

echo "Labeling nodes" 
mapfile -t AGENT_NODES < <(kubectl get nodes -o name | grep agent | sort)
if [ ${#AGENT_NODES[@]} -lt 2 ]; then
    echo "Not enough agent nodes found. Expected at least 2."
    exit 1
fi

CLIENT_NODE="${AGENT_NODES[0]}"
SERVER_NODE="${AGENT_NODES[1]}"

kubectl label "$CLIENT_NODE" role=client --overwrite
kubectl label "$SERVER_NODE" role=server --overwrite


if [ -n "$CLIENT_CPUSET" ] && [ -n "$SERVER_CPUSET" ]; then
    echo "Setting CPU sets for nodes"
    docker update --cpuset-cpus="$CLIENT_CPUSET" "${CLIENT_NODE#node/}"
    docker update --cpuset-cpus="$SERVER_CPUSET" "${SERVER_NODE#node/}"
fi

echo "Verifying nodes "
kubectl get nodes

echo -e "Installing Istio $ISTIO_VERSION profile MINIMAL"
istioctl install --set profile=minimal -y

echo "Enabling Istio sidecar injection for default namespace"
kubectl label namespace default istio-injection=enabled --overwrite

echo "Installing monitoring stack"
kubectl apply -f "https://raw.githubusercontent.com/istio/istio/release-${ISTIO_VERSION%.*}/samples/addons/prometheus.yaml"

kubectl get configmap prometheus -n istio-system -o yaml \
  | sed -e 's/scrape_interval: .*/scrape_interval: 5s/' \
        -e 's/scrape_timeout: .*/scrape_timeout: 4s/' \
  | kubectl apply -f -


kubectl rollout restart deployment prometheus -n istio-system

kubectl apply -f "https://raw.githubusercontent.com/istio/istio/release-${ISTIO_VERSION%.*}/samples/addons/grafana.yaml"
kubectl apply -f "https://raw.githubusercontent.com/istio/istio/release-${ISTIO_VERSION%.*}/samples/addons/kiali.yaml"

echo "Deploying backend service"
kubectl apply -f 02_manifests/backend.yaml

echo "Deploying k6 load generator"
kubectl apply -f 02_manifests/k6.yaml

echo "Waiting for backend service to be ready and k6"

check_rollout() {
  local deploy=$1 app=$2
  if ! kubectl rollout status "deployment/$deploy" -n default --timeout=240s; then
    echo "Deploy rollout timed out. Diagnostics"
    kubectl get pods -n default -l "app=$app" -o wide
    kubectl describe pods -n default -l "app=$app" | tail -40
    exit 1
  fi
}

check_rollout httpbin httpbin
check_rollout k6-deploy k6

./01_scripts/record_env.sh || true

echo "Environment setup complete. Cluster is ready for testing."
echo "Verify by running: kubectl get pods -A"
