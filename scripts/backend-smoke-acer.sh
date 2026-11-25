#!/usr/bin/env bash
set -euo pipefail

if (($# != 0)); then
    echo 'Usage: bash scripts/backend-smoke-acer.sh (run on Acer against kind-em-tst-00)' >&2
    exit 2
fi

# shellcheck source=scripts/env-load.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/env-load.sh"
# shellcheck source=scripts/kind-common.sh
source "$repo/scripts/kind-common.sh"
t() { k -n "$ns" "$@"; }
k wait --for=condition=Ready nodes --all --timeout="$K_READY_WAIT"

scratch=$(mktemp -d)
suffix=${scratch##*.}
ns=backend-smoke-${suffix,,}
image=$BACKEND_IMAGE:smoke-${suffix,,}
created=false
cleanup() {
    local status=$?
    if "$created"; then
        if ((status)); then t get pods,service,endpointslices -o wide || true; fi
        k delete namespace "$ns" --timeout=60s || status=1
    fi
    rm -rf -- "$scratch"
    exit "$status"
}
trap cleanup EXIT

echo 'Building and importing the test image'
cp -- "$repo/backend/src/backend/"{Dockerfile,app.py} "$scratch/"
"$engine" build -t "$image" "$scratch"
load_kind_image "$image"

k create namespace "$ns"
created=true
t create -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: joke-app
spec:
  selector:
    matchLabels: {app: joke-app}
  template:
    metadata:
      labels: {app: joke-app}
    spec:
      containers:
      - name: joke-app
        image: $image
        imagePullPolicy: Never
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet: {path: /, port: 8080}
          periodSeconds: 2
YAML
t expose deployment joke-app --port=80 --target-port=8080
t run smoke-client --image="$image" --image-pull-policy=Never --restart=Never \
    --command -- python -c 'import time; time.sleep(300)'
t wait --for=condition=Ready pod/smoke-client --timeout=45s
t rollout status deployment/joke-app --timeout=60s

assert_http() {
    t exec -i smoke-client -- python - <<'PY'
import time
from urllib.request import urlopen

for attempt in range(15):
    try:
        with urlopen("http://joke-app/", timeout=1) as response:
            body = response.read().decode()
            if response.status != 200 or "(Served by:" not in body:
                raise SystemExit(f"Unexpected HTTP response: {response.status} {body!r}")
            print(f"HTTP 200: {body.strip()}")
            break
    except OSError as error:
        print(f"HTTP attempt {attempt + 1}/15 failed: {error}", flush=True)
        if attempt == 14:
            raise
        time.sleep(1)
PY
}

assert_http
t patch deployment joke-app --type=strategic \
    -p '{"spec":{"template":{"spec":{"containers":[{"name":"joke-app","command":["python","-c","raise SystemExit(1)"]}]}}}}'
if output=$(t rollout status deployment/joke-app --timeout=15s 2>&1); then
    echo 'Bad revision unexpectedly completed' >&2
    exit 1
fi
printf '%s\n' "$output"
grep -Fq 'timed out waiting for the condition' <<< "$output"
echo 'Expected failure: the bad revision did not roll out'
t rollout undo deployment/joke-app
t rollout status deployment/joke-app --timeout=60s
assert_http
echo 'Backend HTTP and rollback checks passed; removing temporary namespace'
