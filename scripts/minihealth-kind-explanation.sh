#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
Objective: Verify the deployed Minihealth frontend can reach the backend through same-origin HTTP.

1. Prepare kind cluster test-0 and deploy joke-app in base-back-front.
   Success: The node and backend Deployment are ready.
   Failure: A cluster or backend error stops Minihealth deployment.
2. Run make minihealth-kind-deploy to build, load, and deploy the frontend.
   Success: The minihealth Deployment rolls out.
   Failure: A build, image load, or rollout error is printed.
3. Run make minihealth-kind-forward and leave it running.
   Success: kubectl listens on 127.0.0.1:8083.
   Failure: The Service is missing, the pod is not ready, or the port is unavailable.
4. Open http://127.0.0.1:8083 and run make minihealth-kind-check in another terminal.
   Success: The page shows three HTTP 200 results and the command prints four PASS lines.
   Failure: A bad response appears on the page or exits the check with an error.
EOF
