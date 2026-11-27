#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT

cat > "$tmp/kubectl" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@"
EOF
cat > "$tmp/curl" <<'EOF'
#!/usr/bin/env bash
case "${!#}" in
    http://127.0.0.1:8084/) printf '<title>Minihealth</title>\n200' ;;
    http://127.0.0.1:8084/api/) printf 'A joke\n(Served by: joke-app-test)\n200' ;;
    http://127.0.0.1:8084/api/health) printf '<title>Minihealth</title>\n200' ;;
    *) exit 7 ;;
esac
EOF
chmod +x "$tmp/kubectl" "$tmp/curl"
export PATH="$tmp:$PATH"
unset PROJECT_ENV_FILE CLUSTER_NAME BACKEND_NAMESPACE MINIHEALTH_PORT

bash scripts/minihealth-kind.sh forward > "$tmp/actual"
printf '%s\n' --context kind-test-0 -n base-back-front port-forward \
    --address 127.0.0.1 service/minihealth 8083:80 > "$tmp/expected"
diff -u "$tmp/expected" "$tmp/actual"

rc=0
PROJECT_ENV_FILE=../env bash scripts/minihealth-kind.sh forward \
    > "$tmp/actual" 2> "$tmp/error" || rc=$?
[[ $rc == 2 && ! -s "$tmp/actual" ]]
printf '%s\n' 'Unknown project env profile: ../env' > "$tmp/expected"
diff -u "$tmp/expected" "$tmp/error"

rc=0
MINIHEALTH_PORT=8084 bash scripts/test-minihealth-kind.sh \
    > "$tmp/actual" 2> "$tmp/error" || rc=$?
[[ $rc == 1 ]]
printf '%s\n' 'PASS /: HTTP 200, expected response' \
    'PASS /api/: HTTP 200, expected response' > "$tmp/expected"
diff -u "$tmp/expected" "$tmp/actual"
printf '%s\n' '/api/health returned an unexpected response.' > "$tmp/expected"
diff -u "$tmp/expected" "$tmp/error"
