#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
export PATH="$scratch:$PATH" KUBECONFIG="$scratch/absent" CLUSTER_NAME=phase1-probe
export K_CLUSTER_MANAGER=KIND KIND_EXPERIMENTAL_PROVIDER=podman
unset PROJECT_ENV_FILE
cd "$repo"
cat > "$scratch/kubectl" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$CALLS"
[[ $1 == --context && $2 == kind-phase1-probe ]]
shift 2
case "$*" in
  'get namespace em-tst-backend em-tst-frontend'|'-n em-tst-backend rollout status deployment/joke-app --timeout='*|'-n em-tst-frontend rollout status deployment/minihealth --timeout='*) ;;
  '-n em-tst-frontend exec deployment/minihealth -- wget -T 10 -qO- http://minihealth/') echo '<title>Minihealth</title>' ;;
  '-n em-tst-frontend exec deployment/minihealth -- wget -T 10 -qO- http://minihealth/api/health') echo "${HEALTH:-Ok}" ;;
  '-n em-tst-frontend exec deployment/minihealth -- wget -T 10 -qO- http://minihealth/api/health/hostname') echo '(Served by: joke-app-a1-b2)' ;;
  '-n em-tst-frontend exec deployment/minihealth -- wget -T 10 -qO- http://minihealth/api/') echo 'Joke (Served by: joke-app-a1-b2)' ;;
  '-n em-tst-backend get pods -l app=joke-app -o name') echo "pod/${POD:-joke-app-a1-b2}" ;;
  *) exit 98 ;;
esac
STUB
chmod +x "$scratch/kubectl"
export CALLS="$scratch/calls"
run() {
  local want=$1 actual=0
  shift
  : > "$CALLS"
  bash scripts/kind-phase1.sh "$@" > "$scratch/out" 2> "$scratch/err" || actual=$?
  [[ $want == "$actual" ]]
}
for args in empty invalid extra; do
  case "$args" in
    empty) run 2 ;;
    invalid) run 2 destroy ;;
    extra) run 2 check unexpected ;;
  esac
  [[ ! -s $CALLS && ! -s $scratch/out ]]
  diff -u <(echo 'Usage: bash scripts/kind-phase1.sh {deploy|check|forward}') "$scratch/err"
done
run 0 check
[[ ! -s $scratch/err && $(wc -l < "$CALLS") == 8 ]]
diff -u <(printf '%s\n' pod/joke-app-a1-b2 'Phase 1 HTTP check passed: Minihealth and all three proxied Flask routes.') "$scratch/out"
HEALTH=error run 1 check
[[ ! -s $scratch/out ]]
diff -u <(echo 'Phase 1 HTTP check failed: unexpected page or backend response') "$scratch/err"
POD=joke-app-other run 1 check
[[ ! -s $scratch/out && ! -s $scratch/err ]]
echo '6 Phase 1 cases passed'
