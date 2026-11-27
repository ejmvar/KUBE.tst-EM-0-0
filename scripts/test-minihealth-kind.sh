#!/usr/bin/env bash
set -euo pipefail

port=${MINIHEALTH_PORT:-8083}
if [[ ! $port =~ ^[1-9][0-9]{0,4}$ ]] || (( port > 65535 )); then
    echo 'Set MINIHEALTH_PORT to a TCP port (1–65535).' >&2
    exit 2
fi
url="http://127.0.0.1:$port"

get() {
    local response
    if ! response=$(curl --silent --show-error --max-time 10 \
        --write-out $'\n%{http_code}' "$url$1"); then
        echo "Cannot reach $url$1. Is the Minihealth port-forward running?" >&2
        return 1
    fi
    if [[ ${response##*$'\n'} != 200 ]]; then
        printf '%s returned HTTP %s, expected 200.\n' "$1" "${response##*$'\n'}" >&2
        return 1
    fi
    printf '%s' "${response%$'\n'*}"
}

expect() {
    local body
    body=$(get "$1")
    if [[ ! $body =~ $2 ]]; then
        printf '%s returned an unexpected response.\n' "$1" >&2
        return 1
    fi
    printf 'PASS %s: HTTP 200, expected response\n' "$1"
}

hostname_pattern='\(Served by: joke-app-[a-z0-9-]+\)'
expect / '<title>Minihealth</title>'
expect /api/ '^.+'$'\n'"$hostname_pattern"'$'
expect /api/health '^Ok$'
expect /api/health/hostname "^$hostname_pattern"'$'
