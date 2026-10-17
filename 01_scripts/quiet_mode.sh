#!/bin/bash
set -e
 
case "$1" in
  on)  kubectl scale deploy prometheus grafana kiali -n istio-system --replicas=0
       sleep 30 ;;
  off) kubectl scale deploy prometheus grafana kiali -n istio-system --replicas=1 ;;
  *)   echo "Usage: $0 on|off"; exit 1 ;;
esac
