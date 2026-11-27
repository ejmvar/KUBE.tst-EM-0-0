#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 1 || ! $1 =~ ^(deploy|check|forward)$ ]]; then
    echo 'Usage: bash scripts/kind-phase1.sh {deploy|check|forward}' >&2
    exit 2
fi

# shellcheck source=scripts/env-load.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/env-load.sh"
# shellcheck source=scripts/kind-common.sh
source "$repo/scripts/kind-common.sh"

backend_ns=em-tst-backend
frontend_ns=em-tst-frontend

apply_app() {
    local namespace=$1 app=$2 manifest=$3 image=$4
    sed "s|IMAGE_PLACEHOLDER|$image|" "$manifest" | k -n "$namespace" apply -f -
    k -n "$namespace" rollout status "deployment/$app" --timeout="$K_ROLLOUT_WAIT"
}

fetch_frontend() {
    k -n "$frontend_ns" exec deployment/minihealth -- wget -T 10 -qO- "http://minihealth$1"
}

check_phase1() {
    local page health hostname joke pod
    k get namespace "$backend_ns" "$frontend_ns"
    k -n "$backend_ns" rollout status deployment/joke-app --timeout="$K_ROLLOUT_WAIT"
    k -n "$frontend_ns" rollout status deployment/minihealth --timeout="$K_ROLLOUT_WAIT"
    page=$(fetch_frontend /)
    health=$(fetch_frontend /api/health)
    hostname=$(fetch_frontend /api/health/hostname)
    joke=$(fetch_frontend /api/)
    if [[ $page != *'<title>Minihealth</title>'* || $health != 'Ok' ||
          ! $hostname =~ ^\(Served\ by:\ (joke-app-[a-z0-9-]+)\)$ ||
          $joke != *"$hostname" ]]; then
        echo 'Phase 1 HTTP check failed: unexpected page or backend response' >&2
        return 1
    fi
    pod=${BASH_REMATCH[1]}
    k -n "$backend_ns" get pods -l app=joke-app -o name | grep -Fx "pod/$pod"
    echo 'Phase 1 HTTP check passed: Minihealth and all three proxied Flask routes.'
}

case "$1" in
    deploy)
        k wait --for=condition=Ready nodes --all --timeout="$K_READY_WAIT"
        backend_image="$BACKEND_IMAGE:$BACKEND_VERSION"
        if ! "$engine" image inspect "$backend_image" >/dev/null 2>&1; then
            bash "$repo/scripts/backend-kind.sh" build
        fi
        bash "$repo/scripts/backend-kind.sh" load
        for namespace in "$backend_ns" "$frontend_ns"; do
            k create namespace "$namespace" --dry-run=client -o yaml | k apply -f -
        done
        apply_app "$backend_ns" joke-app "$repo/backend/kind.yaml" "$backend_image"

        scratch=$(mktemp -d)
        trap 'rm -rf -- "$scratch"' EXIT
        "$engine" build --iidfile "$scratch/frontend-id" "$repo/front/minihealth"
        frontend_id=$(<"$scratch/frontend-id")
        frontend_image="localhost/phase1-minihealth:${frontend_id#sha256:}"
        "$engine" tag "$frontend_id" "$frontend_image"
        load_kind_image "$frontend_image"
        apply_app "$frontend_ns" minihealth "$repo/front/minihealth/kind.yaml" "$frontend_image"
        ;;
    check) check_phase1 ;;
    forward)
        exec kubectl --context "kind-$cluster" -n "$frontend_ns" port-forward --address 127.0.0.1 \
            service/minihealth "${PHASE1_PORT:-8083}:80"
        ;;
esac
