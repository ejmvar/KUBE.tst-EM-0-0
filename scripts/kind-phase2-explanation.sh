#!/usr/bin/env bash
set -euo pipefail
cat <<'EOF'
Objective: Reach Minihealth privately through the host's Tailscale machine name.
1. Start the Phase 1 loopback forward in a separate terminal.
   Success: It reports forwarding on 127.0.0.1:8083.
   Failure: Check the Phase 1 deployment and local port.
2. Start the foreground Tailscale Serve proxy.
   Success: Serve prints the tailnet URL. Leave it running.
   Failure: Check Tailscale login, permissions, existing Serve routes, and the port.
3. From an authorized tailnet device, open the printed URL or run the Phase 2 check.
   Success: Minihealth and the three proxied backend endpoints respond.
   Failure: Check tailnet DNS, access policy, and both foreground processes.
4. Optionally run the offline Phase 2 test before changing the workflow.
   Success: The stubbed routing and input checks pass.
   Failure: Inspect the failing test; the offline test does not prove live connectivity.
EOF
