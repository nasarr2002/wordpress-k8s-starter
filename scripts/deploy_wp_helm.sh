#!/usr/bin/env bash
set -euo pipefail
NS=wordpress
kubectl create namespace ${NS} || true
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm upgrade --install wordpress bitnami/wordpress -n ${NS} -f infra/helm/wordpress/values-dev.yaml
kubectl -n ${NS} rollout status deploy/wordpress
minikube service -n ${NS} wordpress --url
