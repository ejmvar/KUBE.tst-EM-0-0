#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/env-load.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/env-load.sh"
cd "$repo/backend"
exec uv run --locked flask --app backend.app run --host 127.0.0.1 --port "${BACKEND_PORT:-$BACKEND_LOCAL_PORT}"
