#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
export PATH="$scratch:$PATH" CALLS="$scratch/calls"
export KIND_EXPERIMENTAL_PROVIDER=podman
for tool in podman kind kubectl; do
    cat > "$scratch/$tool" <<'SH'
#!/usr/bin/env bash
printf '%s %s\n' "${0##*/}" "$*" >> "$CALLS"
case "${0##*/} $*" in
    'podman image ls '*) printf '%s' "${EXISTING_TAGS:-}" ;;
    'kind get nodes '*) printf 'em-tst-00-control-plane\n' ;;
    *' get namespace '*) printf 'namespace/backend-lab\n' ;;
    *' get deployment '*) printf 'deployment.apps/joke-app\n' ;;
esac
SH
    chmod +x "$scratch/$tool"
done
run() { bash "$repo/scripts/backend-kind.sh" "$@"; }
if BACKEND_VERSION=01.2.3 run build; then exit 1; fi
test ! -e "$CALLS"
if EXISTING_TAGS=localhost/joke-app:1.2.3 BACKEND_VERSION=1.2.3 run build; then exit 1; fi
if grep -q 'podman build' "$CALLS"; then exit 1; fi
BACKEND_VERSION=1.2.4 run build
BACKEND_VERSION=1.2.4 run load
BACKEND_VERSION=1.2.4 run rollout
grep -Fq 'podman build --tag localhost/joke-app:1.2.4' "$CALLS"
grep -Fq 'kind load image-archive --name em-tst-00' "$CALLS"
grep -Fq 'kubectl --context kind-em-tst-00 -n backend-lab set image deployment/joke-app joke-app=localhost/joke-app:1.2.4' "$CALLS"
grep -Fq 'rollout status deployment/joke-app --timeout=90s' "$CALLS"

unset BACKEND_VERSION
expected_version=$(bash -c 'source "$1/env"; printf "%s" "$BACKEND_VERSION"' _ "$repo")
CLUSTER_NAME=alternate-lab BACKEND_NAMESPACE=alternate-ns K_ROLLOUT_WAIT=25s run rollout
grep -Fq "kubectl --context kind-alternate-lab -n alternate-ns set image deployment/joke-app joke-app=localhost/joke-app:$expected_version" "$CALLS"
grep -Fq 'rollout status deployment/joke-app --timeout=25s' "$CALLS"
