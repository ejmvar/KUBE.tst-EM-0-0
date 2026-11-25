#!/usr/bin/env bash
cat <<'TEXT'
Objective: build a versioned image locally, load it into kind, and deploy or roll out the app.

1. Check the existing cluster with mise run kind:phase0:check.
   Success: node is Ready. Failure: start the intended lab or fix kubeconfig before proceeding.
2. Set BACKEND_VERSION in the root env file; choose a new stable X.Y.Z for each new build.
   Run mise run backend:kind:build.
   Success: localhost/joke-app:<version> exists locally. Failure: bad version, duplicate tag, or build error stops here.
3. Run mise run backend:kind:load.
   Success: the image is present in every kind node's local image store. Failure: check provider, cluster, and tag.
   This is a local import, not a registry push.
4. First release: mise run backend:kind:deploy. Later versions: mise run backend:kind:rollout.
   Success: deployment/joke-app successfully rolled out in backend-lab.
   Failure: a missing node image or rollout error exits nonzero. Inspect the pods before retrying.
5. In one terminal run mise run backend:kind:forward; in another run
   BACKEND_PORT=8082 mise run backend:local:check.
   Success: all three routes return HTTP 200. Failure: check port forwarding, readiness, or the reported route.
   Stop the foreground forward with Ctrl-C. Port 8080 is not changed.

Make and Just targets: backend-kind-build, backend-kind-load, backend-kind-deploy,
backend-kind-rollout, backend-kind-forward, backend-kind-explanation.
The default provider is Podman; set KIND_EXPERIMENTAL_PROVIDER=docker for a Docker-backed kind cluster.
TEXT
