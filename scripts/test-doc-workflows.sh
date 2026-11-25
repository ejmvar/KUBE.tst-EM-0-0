#!/usr/bin/env bash
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
export PATH="$scratch:$PATH" TEST_CALLS="$scratch/calls"
for name in ssh sudo kubectl podman kind mise; do
    cat > "$scratch/$name" <<'SH'
#!/usr/bin/env bash
echo "${0##*/} $*" >> "$TEST_CALLS"
if [[ ${0##*/} == kind && $* == 'get clusters' ]]; then
    printf '%s\n' "${TEST_EXISTING:-}"
fi
if [[ ${0##*/} == kubectl ]]; then
    case " $* " in
        *' create -f - '*|*' exec -i smoke-client '*) cat >/dev/null ;;
        *' rollout status deployment/joke-app --timeout=15s '*)
            if [[ ${TEST_BAD_ROLLOUT_SUCCEEDS:-} != yes ]]; then
                echo 'error: timed out waiting for the condition' >&2
                exit 1
            fi
            ;;
    esac
fi
SH
    chmod +x "$scratch/$name"
done

for name in kind-phase0 backend-smoke-acer; do
    output=$(bash "$repo/scripts/$name-explanation.sh")
    grep -Fq 'Objective:' <<< "$output"
    grep -Fq 'Success:' <<< "$output"
    grep -Fq 'Failure:' <<< "$output"
done
test ! -e "$TEST_CALLS"

if TEST_EXISTING=em-tst-00 bash "$repo/scripts/kind-phase0.sh" smoke > "$scratch/output" 2>&1; then
    echo 'Smoke test must refuse a pre-existing lab' >&2
    exit 1
fi
grep -Fq 'Refusing to use existing em-tst-00' "$scratch/output"
test "$(cat "$TEST_CALLS")" = 'kind get clusters'
: > "$TEST_CALLS"
bash "$repo/scripts/kind-phase0.sh" smoke
grep -Fq 'kind create cluster --name em-tst-00' "$TEST_CALLS"
grep -Fq 'kubectl --context kind-em-tst-00 wait' "$TEST_CALLS"
grep -Fxq 'kind delete cluster --name em-tst-00' "$TEST_CALLS"

: > "$TEST_CALLS"
if bash "$repo/scripts/backend-smoke-acer.sh" unexpected > "$scratch/output" 2>&1; then
    echo 'Smoke test must reject unexpected arguments' >&2
    exit 1
fi
grep -Fq 'Usage:' "$scratch/output"
test ! -s "$TEST_CALLS"

bash "$repo/scripts/backend-smoke-acer.sh"
grep -Fq 'kind load image-archive --name em-tst-00' "$TEST_CALLS"
test "$(grep -Fc 'exec -i smoke-client -- python -' "$TEST_CALLS")" -eq 2
grep -Fq 'rollout undo deployment/joke-app' "$TEST_CALLS"
grep -Fq 'delete namespace backend-smoke-' "$TEST_CALLS"

: > "$TEST_CALLS"
if TEST_BAD_ROLLOUT_SUCCEEDS=yes bash "$repo/scripts/backend-smoke-acer.sh" > "$scratch/output" 2>&1; then
    echo 'A successful bad rollout must fail the smoke test' >&2
    exit 1
fi
grep -Fq 'Bad revision unexpectedly completed' "$scratch/output"
grep -Fq 'delete namespace backend-smoke-' "$TEST_CALLS"
! grep -Fq 'rollout undo' "$TEST_CALLS"
