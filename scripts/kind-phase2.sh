#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 1 || ! $1 =~ ^(serve|check)$ ]]; then
    echo 'Usage: bash scripts/kind-phase2.sh {serve|check}' >&2
    exit 2
fi

local_port=${PHASE1_PORT:-8083}
serve_port=${PHASE2_PORT:-8085}
for port in "$local_port" "$serve_port"; do
    if [[ ! $port =~ ^[0-9]{1,5}$ ]] || (( 10#$port < 1 || 10#$port > 65535 )); then
        echo "Invalid port: $port" >&2
        exit 2
    fi
done

case "$1" in
    serve)
        exec tailscale serve --http "$serve_port" "http://127.0.0.1:$local_port"
        ;;
    check)
        : "${PHASE2_HOST:?Set PHASE2_HOST to the Tailscale machine name}"
        if [[ ! $PHASE2_HOST =~ ^[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?$ ]]; then
            echo 'Invalid Tailscale hostname' >&2
            exit 2
        fi
        base="http://$PHASE2_HOST:$serve_port"
        page=$(curl --fail --silent --show-error --max-time 10 "$base/")
        [[ $page == *'<title>Minihealth</title>'* ]] || { echo 'Unexpected Minihealth page' >&2; exit 1; }
        health=$(curl --fail --silent --show-error --max-time 10 "$base/api/health")
        [[ $health == Ok ]] || { echo 'Unexpected backend health response' >&2; exit 1; }
        hostname=$(curl --fail --silent --show-error --max-time 10 "$base/api/health/hostname")
        [[ $hostname == '(Served by: joke-app-'*')' ]] || { echo 'Unexpected backend hostname' >&2; exit 1; }
        joke=$(curl --fail --silent --show-error --max-time 10 "$base/api/")
        [[ $joke == *'(Served by: joke-app-'*')'* ]] || { echo 'Unexpected backend joke response' >&2; exit 1; }
        echo "Phase 2 check passed: $base/"
        ;;
esac
