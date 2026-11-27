#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
Objective: Run Minihealth and Flask in two namespaces on the selected local kind cluster.

1. Deploy: verify nodes are Ready, create both namespaces, then deploy Flask and Minihealth in that order.
   Success: Both Deployments complete their rollouts.
   Failure: Check cluster readiness, image build/load output, and rollout events in the failing namespace.
2. Check: request the Minihealth page and three Flask routes through the frontend Service.
   Success: Minihealth responds and Flask's hostname identifies a pod in the backend namespace.
   Failure: Check Pod readiness, Service endpoints, and NGINX logs.
3. Forward (optional): expose Minihealth on 127.0.0.1:8083 until Ctrl-C.
   Success: The browser renders three successful HTTP responses.
   Failure: Check for a busy local port or rerun the HTTP check.
EOF
