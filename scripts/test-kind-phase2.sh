#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
export PATH="$scratch:$PATH" CALLS="$scratch/calls"
cat > "$scratch/tailscale" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$CALLS"
SH
cat > "$scratch/curl" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$CALLS"
case "${*: -1}" in
    */api/health) echo Ok ;;
    */api/health/hostname) echo '(Served by: joke-app-abc)' ;;
    */api/) echo 'Joke (Served by: joke-app-abc)' ;;
    */) echo '<title>Minihealth</title>' ;;
    *) exit 1 ;;
esac
SH
chmod +x "$scratch/tailscale" "$scratch/curl"
bash "$repo/scripts/kind-phase2.sh" serve
grep -Fxq 'serve --http 8085 http://127.0.0.1:8083' "$CALLS"
: > "$CALLS"
PHASE1_PORT=8084 PHASE2_PORT=9999 bash "$repo/scripts/kind-phase2.sh" serve
grep -Fxq 'serve --http 9999 http://127.0.0.1:8084' "$CALLS"
: > "$CALLS"
PHASE2_HOST=lab.example.test bash "$repo/scripts/kind-phase2.sh" check
test "$(wc -l < "$CALLS")" -eq 4
for value in 0 65536 bad; do
    if PHASE2_PORT=$value bash "$repo/scripts/kind-phase2.sh" serve >/dev/null 2>&1; then
        echo "Invalid port accepted: $value" >&2
        exit 1
    fi
done
if PHASE2_HOST='bad/name' bash "$repo/scripts/kind-phase2.sh" check >/dev/null 2>&1; then
    echo 'Invalid hostname accepted' >&2
    exit 1
fi
echo 'Phase 2 routing tests passed.'
