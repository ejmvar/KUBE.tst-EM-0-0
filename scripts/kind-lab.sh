#!/usr/bin/env bash
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cluster=em-tst-00

case "${1:-}" in
    up) kind create cluster --name "$cluster" --config "$repo/kind-lab.yaml" --wait 120s ;;
    check)
        kubectl --context "kind-$cluster" cluster-info
        kubectl --context "kind-$cluster" wait --for=condition=Ready nodes --all --timeout=60s
        ;;
    down) kind delete cluster --name "$cluster" ;;
    *) echo "Usage: bash scripts/kind-lab.sh {up|check|down}" >&2; exit 2 ;;
esac
