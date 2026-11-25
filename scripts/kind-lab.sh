#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/env-load.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/env-load.sh"
# shellcheck source=scripts/kind-common.sh
source "$repo/scripts/kind-common.sh"

case "${1:-}" in
    up) kind create cluster --name "$cluster" --config "$repo/kind-lab.yaml" --wait "$K_CREATE_WAIT" ;;
    check)
        k cluster-info
        k wait --for=condition=Ready nodes --all --timeout="$K_READY_WAIT"
        ;;
    namespace)
        existing=$(k get namespace "$BACKEND_NAMESPACE" --ignore-not-found -o name)
        if [[ -z $existing ]]; then k create namespace "$BACKEND_NAMESPACE"; fi
        k get namespace "$BACKEND_NAMESPACE"
        ;;
    down) kind delete cluster --name "$cluster" ;;
    *) echo "Usage: bash scripts/kind-lab.sh {up|check|namespace|down}" >&2; exit 2 ;;
esac
