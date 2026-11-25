#!/usr/bin/env bash

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

load_project_env() {
    local key
    local -A overrides=()
    for key in K_CLUSTER_MANAGER KIND_EXPERIMENTAL_PROVIDER CLUSTER_NAME K_CREATE_WAIT \
        K_READY_WAIT K_ROLLOUT_WAIT BACKEND_VERSION BACKEND_IMAGE \
        BACKEND_NAMESPACE BACKEND_LOCAL_PORT BACKEND_FORWARD_PORT; do
        if [[ -v $key ]]; then overrides[$key]=${!key}; fi
    done
    # shellcheck source=env
    source "$repo/env" || return
    if [[ -n ${PROJECT_ENV_FILE:-} ]]; then
        if [[ ! $PROJECT_ENV_FILE =~ ^env\.[a-zA-Z0-9._-]+$ || ! -f $repo/$PROJECT_ENV_FILE ]]; then
            echo "Unknown project env profile: $PROJECT_ENV_FILE" >&2
            return 2
        fi
        # shellcheck source=/dev/null
        source "$repo/$PROJECT_ENV_FILE" || return
    fi
    for key in "${!overrides[@]}"; do
        printf -v "$key" '%s' "${overrides[$key]}"
    done
}

load_project_env
