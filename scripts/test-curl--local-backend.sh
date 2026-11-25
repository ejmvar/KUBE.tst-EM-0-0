#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/env-load.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/env-load.sh"
base="http://localhost:${BACKEND_PORT:-$BACKEND_LOCAL_PORT}"
failed=0
for path in / /health /health/hostname; do
    if ! response=$(curl --noproxy '*' --silent --show-error --max-time 5 \
        --write-out $'\n%{http_code}' "$base$path"); then
        printf 'FAIL GET %s: connection failed\n' "$path" >&2
        failed=1
        continue
    fi
    status=${response##*$'\n'}
    body=${response%$'\n'*}
    printf 'GET %s -> HTTP %s\n' "$path" "$status"
    if [[ $status == 200 ]]; then
        case "$path" in
            /) [[ $body =~ ^[^$'\n']+$'\n'\(Served\ by:\ [^$'\n']+\)$'\n'$ ]] && continue ;;
            /health) [[ $body == Ok ]] && continue ;;
            /health/hostname) [[ $body =~ ^\(Served\ by:\ [^$'\n']+\)$'\n'$ ]] && continue ;;
        esac
    fi
    printf 'FAIL GET %s: unexpected status or response body\n' "$path" >&2
    failed=1
done
exit "$failed"
