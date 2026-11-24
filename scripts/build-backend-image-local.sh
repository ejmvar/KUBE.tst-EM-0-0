#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
exec docker build -t joke-app:1.0 -f backend/src/backend/Dockerfile backend
