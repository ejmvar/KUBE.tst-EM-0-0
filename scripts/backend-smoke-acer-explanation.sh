#!/usr/bin/env bash
cat <<'TEXT'
Objective: prove that the Flask backend returns HTTP 200 through a Service
and returns to a working release after a failed deployment.

1. From the workstation, stage the lab with mise run kind:phase0:stage-acer,
   then ssh acer and cd to the printed path. Skip staging for a complete checkout.
   Success: the staged project contains the backend Dockerfile and app.py.
   Failure: fix SSH, file transfer, or missing prerequisites before proceeding.
2. On Acer, run mise run kind:phase0:check, then mise run backend:smoke-acer.
   Success: the existing kind-em-tst-00 node is Ready. Podman builds the
   test image and kind imports it into that node. No cluster is recreated.
   Failure: a node, image build, or import error stops the smoke test.
3. The script deploys the app and a separate client in a temporary namespace.
   Success: rollout completes and the client prints HTTP 200 with (Served by: ...).
   Failure: a brief connection refusal is retried; persistent failure stops the test.
4. The script deploys an intentionally bad revision and rolls it back.
   Success: the bad rollout reports a timeout (expected), then rollback
   completes and the client prints HTTP 200 again.
   Failure: unexpected rollout success, another error, or failed recovery exits nonzero.
5. The script deletes its own namespace and temporary build files.
   Success: namespace deletion is confirmed; the cluster and cached test image remain.
   Failure: a cleanup error is reported and exits nonzero.

Run make backend-smoke-acer or just backend-smoke-acer for the same test.
This tests in-cluster HTTP, not LAN access.
TEXT
