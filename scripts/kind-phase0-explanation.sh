#!/usr/bin/env bash
cat <<'TEXT'
Objective: prove that pinned kind can create, check, and remove a disposable cluster.

1. Stage on Acer (optional, from workstation): mise run kind:phase0:stage-acer
   Success: prints the remote directory. Run ssh acer and cd there.
   Failure: SSH or archive fails; do not proceed with a partial copy.
2. Prepare the target: install mise and rootless Podman as documented, then
   run mise run kind:phase0:preflight to identify the host and verify the runtime.
   Success: rootless=true cgroups=v2 under Podman, or a reachable Docker API.
   Failure: missing prerequisites or unusable runtime; fix before creating nodes.
3. Install project tools: mise run kind:phase0:install-tools
   Success: kind v0.33.0 and kubectl v1.37.1.
   Failure: inspect the mise trust or download error.
4. Choose a check:
   Existing cluster: mise run kind:phase0:check (read-only).
   Disposable cluster: mise run kind:phase0:smoke (create, check, delete).
   Success: API responds and em-tst-00-control-plane reports condition met.
   The disposable run also prints a deletion result and uses a temporary kubeconfig.
   Failure: existing em-tst-00 is refused before any mutation; use check instead.
   If create fails, investigate the runtime or image pull; no existing cluster is deleted.

Make and Just expose the same actions with hyphens: kind-phase0-stage-acer,
kind-phase0-preflight, kind-phase0-install-tools, kind-phase0-check, kind-phase0-smoke.
Kiri, if already approved and installed, uses kind's Docker provider and the
explicit Kiri socket; see docs/phase-0-kind-lab.md. It is not the default.
TEXT
