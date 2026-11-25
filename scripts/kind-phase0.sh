#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/env-load.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/env-load.sh"
# shellcheck source=scripts/kind-common.sh
source "$repo/scripts/kind-common.sh"
cd "$repo"

case "${1:-}" in
    stage-acer)
        ssh_opts=(-o BatchMode=yes -o ConnectTimeout=8 -o StrictHostKeyChecking=yes)
        lab_dir=$(ssh "${ssh_opts[@]}" acer 'mktemp -d "$HOME/kind-phase0.XXXXXXXX"')
        if [[ ! $lab_dir =~ ^/[[:alnum:]_./-]+/kind-phase0\.[[:alnum:]]{8}$ ]]; then
            echo 'Unexpected staging path; no files sent' >&2
            exit 1
        fi
        remote_extract="tar -xf - -C '$lab_dir'"
        # The allowlisted path is generated on Acer and intentionally expanded here.
        # shellcheck disable=SC2029
        tar -cf - env env.em-test-0-0.my-dev-0-0-0 mise.toml Makefile justfile kind-lab.yaml mise/tasks/kind.toml \
            scripts/env-load.sh scripts/kind-common.sh \
            mise/tasks/backend-kind.toml mise/tasks/backend-local.toml backend/kind.yaml \
            scripts/backend-kind.sh scripts/backend-kind-explanation.sh \
            scripts/backend-local-serve.sh scripts/backend-local-explanation.sh \
            scripts/test-curl--local-backend.sh backend/pyproject.toml backend/uv.lock \
            backend/.python-version backend/README.md backend/src/backend/__init__.py \
            docs/backend-kind.md docs/backend-local.md docs/kind-profile-rebuild.md \
            scripts/kind-profile-rebuild-explanation.sh \
            scripts/kind-lab.sh scripts/test-kind-lab.sh scripts/kind-phase0.sh \
            scripts/kind-phase0-explanation.sh scripts/backend-smoke-acer.sh \
            scripts/backend-smoke-acer-explanation.sh backend/src/backend/Dockerfile \
            backend/src/backend/app.py README.md docs/phase-0-kind-lab.md \
            docs/backend-smoke-acer.md |
            ssh "${ssh_opts[@]}" acer "$remote_extract"
        printf 'On acer, run: cd %q\n' "$lab_dir"
        ;;
    preflight)
        hostname
        cat /etc/os-release
        uname -m
        mise --version
        case "$KIND_EXPERIMENTAL_PROVIDER" in
            podman)
                podman --version
                status=$(podman info --format 'rootless={{.Host.Security.Rootless}} cgroups={{.Host.CgroupsVersion}}')
                printf '%s\n' "$status"
                [[ $status == 'rootless=true cgroups=v2' ]] || {
                    echo 'Expected rootless Podman with cgroup v2' >&2
                    exit 1
                }
                ;;
            docker) docker version ;;
            *) echo 'Expected podman or docker provider' >&2; exit 2 ;;
        esac
        ;;
    install-tools)
        mise install kind kubectl
        mise exec -- kind version
        mise exec -- kubectl version --client
        ;;
    check)
        kind get clusters
        bash scripts/kind-lab.sh check
        ;;
    smoke)
        clusters=$(kind get clusters)
        if grep -Fxq -- "$cluster" <<< "$clusters"; then
            echo "Refusing to use existing $cluster cluster; run the read-only check instead" >&2
            exit 1
        fi
        scratch=$(mktemp -d)
        created=false
        cleanup() {
            local status=$?
            if "$created"; then bash scripts/kind-lab.sh down || status=1; fi
            rm -rf -- "$scratch"
            exit "$status"
        }
        trap cleanup EXIT
        export KUBECONFIG="$scratch/kubeconfig"
        bash scripts/test-kind-lab.sh
        bash scripts/kind-lab.sh up
        created=true
        bash scripts/kind-lab.sh check
        ;;
    *) echo 'Usage: bash scripts/kind-phase0.sh {stage-acer|preflight|install-tools|check|smoke}' >&2; exit 2 ;;
esac
