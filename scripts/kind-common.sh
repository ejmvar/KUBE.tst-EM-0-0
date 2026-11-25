#!/usr/bin/env bash

if [[ $K_CLUSTER_MANAGER != KIND ]]; then
    echo "Unsupported K_CLUSTER_MANAGER: $K_CLUSTER_MANAGER (expected KIND)" >&2
    return 2
fi

engine=$KIND_EXPERIMENTAL_PROVIDER
case "$engine" in
    podman|docker) export KIND_EXPERIMENTAL_PROVIDER="$engine" ;;
    *) echo "Unsupported KIND_EXPERIMENTAL_PROVIDER: $engine (expected podman or docker)" >&2; return 2 ;;
esac

cluster=$CLUSTER_NAME
k() { kubectl --context "kind-$cluster" "$@"; }

load_kind_image() (
    local image=$1 scratch
    scratch=$(mktemp -d)
    trap 'rm -rf -- "$scratch"' EXIT
    if [[ $engine == podman ]]; then
        podman save --format docker-archive -o "$scratch/image.tar" "$image"
    else
        docker save -o "$scratch/image.tar" "$image"
    fi
    kind load image-archive --name "$cluster" "$scratch/image.tar"
)

require_node_image() {
    local image=$1 nodes node
    nodes=$(kind get nodes --name "$cluster")
    [[ -n $nodes ]] || { echo "No nodes found in $cluster" >&2; return 1; }
    while IFS= read -r node; do
        if ! "$engine" exec "$node" crictl inspecti "$image" >/dev/null; then
            echo "Image $image is missing on $node; run backend:kind:load first" >&2
            return 1
        fi
    done <<< "$nodes"
}
