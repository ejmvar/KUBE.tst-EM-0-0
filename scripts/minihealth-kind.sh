#!/usr/bin/env bash
set -euo pipefail

PROJECT_ENV_FILE=${PROJECT_ENV_FILE:-env.test-0.base-back-front}
# shellcheck source=scripts/env-load.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/env-load.sh"
# shellcheck source=scripts/kind-common.sh
source "$repo/scripts/kind-common.sh"

n() { k -n "$BACKEND_NAMESPACE" "$@"; }

case "${1:-}" in
    deploy)
        n rollout status deployment/joke-app --timeout="$K_ROLLOUT_WAIT"
        n get service joke-app -o name
        front="$repo/front/minihealth"
        scratch=$(mktemp -d)
        trap 'rm -rf -- "$scratch"' EXIT
        "$engine" build --iidfile "$scratch/image-id" "$front"
        id=$(cat "$scratch/image-id")
        digest=${id#sha256:}
        if [[ ! $digest =~ ^[0-9a-f]{64}$ ]]; then
            echo 'Container build did not return a valid image ID.' >&2
            exit 1
        fi
        image="localhost/minihealth:$digest"
        "$engine" tag "$id" "$image"
        load_kind_image "$image"
        sed "s|IMAGE_PLACEHOLDER|$image|" "$front/kind.yaml" | n apply -f -
        n rollout status deployment/minihealth --timeout="$K_ROLLOUT_WAIT"
        ;;
    forward)
        exec kubectl --context "kind-$cluster" -n "$BACKEND_NAMESPACE" port-forward \
            --address 127.0.0.1 service/minihealth "${MINIHEALTH_PORT:-8083}:80"
        ;;
    *)
        echo 'Usage: bash scripts/minihealth-kind.sh {deploy|forward}' >&2
        exit 2
        ;;
esac
