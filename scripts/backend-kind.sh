#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/env-load.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/env-load.sh"
# shellcheck source=scripts/kind-common.sh
source "$repo/scripts/kind-common.sh"
action=${1:-}
namespace=$BACKEND_NAMESPACE
n() { k -n "$namespace" "$@"; }

case "$action" in
    forward) exec kubectl --context "kind-$cluster" -n "$namespace" port-forward \
        --address 127.0.0.1 service/joke-app "${BACKEND_PORT:-$BACKEND_FORWARD_PORT}:80" ;;
    build|load|deploy|rollout) ;;
    *) echo 'Usage: BACKEND_VERSION=x.y.z bash scripts/backend-kind.sh {build|load|deploy|rollout|forward}' >&2; exit 2 ;;
esac

version=${BACKEND_VERSION:-}
if [[ ! $version =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ || ${#version} -gt 128 ]]; then
    echo 'Set BACKEND_VERSION to a stable SemVer (MAJOR.MINOR.PATCH, for example 0.1.0)' >&2
    exit 2
fi
if [[ ! $BACKEND_IMAGE =~ ^[a-z0-9][a-z0-9._-]*(/[a-z0-9][a-z0-9._-]*)+$ ]]; then
    echo 'Set BACKEND_IMAGE to an untagged image name such as localhost/joke-app' >&2
    exit 2
fi
image="$BACKEND_IMAGE:$version"

case "$action" in
    build)
        tags=$("$engine" image ls --format '{{.Repository}}:{{.Tag}}' \
            --filter "reference=$image")
        if [[ -n $tags ]]; then
            echo "Image $image already exists; choose a new BACKEND_VERSION" >&2
            exit 1
        fi
        "$engine" build --tag "$image" "$repo/backend/src/backend"
        ;;
    load)
        load_kind_image "$image"
        require_node_image "$image"
        ;;
    deploy)
        require_node_image "$image"
        existing_namespace=$(k get namespace "$namespace" --ignore-not-found -o name)
        if [[ -z $existing_namespace ]]; then
            k create namespace "$namespace"
        fi
        existing_deployment=$(n get deployment joke-app --ignore-not-found -o name)
        if [[ -n $existing_deployment ]]; then
            echo 'Deployment already exists; run backend:kind:rollout instead' >&2
            exit 1
        fi
        sed "s|IMAGE_PLACEHOLDER|$image|" "$repo/backend/kind.yaml" | n apply -f -
        n rollout status deployment/joke-app --timeout="$K_ROLLOUT_WAIT"
        ;;
    rollout)
        require_node_image "$image"
        n set image deployment/joke-app "joke-app=$image"
        n rollout status deployment/joke-app --timeout="$K_ROLLOUT_WAIT"
        ;;
esac
