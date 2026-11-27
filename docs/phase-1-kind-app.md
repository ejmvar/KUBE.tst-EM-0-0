# Phase 1: Deploy Flask and Minihealth in two namespaces

Run Flask in `em-tst-backend` and Minihealth in `em-tst-frontend`. These are
workload namespaces for this kind exercise, not versioned release namespaces.
NGINX serves the built React app and sends same-origin `/api/` requests to
Flask over cluster DNS. Both Services are ClusterIP; namespaces alone do
not enforce network isolation.

## Deploy, check, and open

Start with a ready [Phase 0 kind cluster](phase-0-kind-lab.md) and the same
container provider. The commands target the `kind-` context derived from
`CLUSTER_NAME` (default `em-tst-00`). For the existing `test-0` lab, export
`CLUSTER_NAME=test-0` in each terminal first.

| Action | Make | Just | mise |
| --- | --- | --- | --- |
| Explain (read-only) | `make kind-phase1-explanation` | `just kind-phase1-explanation` | `mise run kind:phase1:explanation` |
| Deploy | `make kind-phase1-deploy` | `just kind-phase1-deploy` | `mise run kind:phase1:deploy` |
| Check | `make kind-phase1-check` | `just kind-phase1-check` | `mise run kind:phase1:check` |
| Open a loopback port | `make kind-phase1-forward` | `just kind-phase1-forward` | `mise run kind:phase1:forward` |

The [explanation script](../scripts/kind-phase1-explanation.sh) lists the
ordered steps and their success and failure signals. The deploy task loads
the existing versioned backend image or builds it if absent. It waits for
Flask before deploying Minihealth. Builds on a cold machine need registry
access for the base images and build dependencies. No host Python or Node.js
installation is needed.

The check waits for both rollouts, requests the Minihealth HTML and all
three `/api/` routes through the frontend Service, and confirms the hostname
response names a Flask pod in `em-tst-backend`. It exits nonzero on failure.
After starting the forward, open <http://127.0.0.1:8083> and expect HTTP 200
on `/`, `/health`, and `/health/hostname` in the Minihealth cards. Use Ctrl-C
to stop forwarding, or set `PHASE1_PORT` if 8083 is busy.

## If a step fails

- An image failure usually means the selected runtime differs from the
  one running kind, or the build cannot download a dependency.
- For rollout or HTTP failures, inspect the Pods and Services in these two
  namespaces. Use the selected `kind-` context explicitly.
- Phase 1 does not change `backend-lab` or remove the cluster. It does not
  add a gateway, database, or network policy.
