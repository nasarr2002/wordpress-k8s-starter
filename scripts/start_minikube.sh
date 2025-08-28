#!/usr/bin/env bash
set -euo pipefail
minikube start --cpus=4 --memory=8192 --driver=docker
kubectl get nodes -o wide
