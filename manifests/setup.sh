#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Creating kind cluster..."
kind create cluster --config ~/komp/manifests/komp-cluster/kindconfig.yaml

echo "[2/4] Waiting for nodes to be Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=180s

kubectl config rename-context kind-komp-cluster komp-cluster