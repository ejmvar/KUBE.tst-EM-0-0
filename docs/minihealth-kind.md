# Verify Minihealth in kind

From the repository root, start a localhost-only forward to the Minihealth
Service in `test-0`, namespace `base-back-front`:

```bash
make minihealth-kind-forward
```

Keep it running and open <http://127.0.0.1:8083>. All three cards should show
**HTTP 200**:

| Card | Expected response |
| --- | --- |
| `/` | A joke followed by `(Served by: joke-app-…)` |
| `/health` | `Ok` |
| `/health/hostname` | `(Served by: joke-app-…)` |

In a second terminal, run `make minihealth-kind-check`. It should exit `0`
and print four `PASS` lines: one for the HTML and one for each API route.
These requests go through Minihealth, not directly to Flask. Ctrl+C stops
the forward without stopping either Deployment.

## Deploy to a fresh local cluster

Use kind, kubectl, and a working container runtime. From the repository root:

```bash
export PROJECT_ENV_FILE=env.test-0.base-back-front
make kind-up
make kind-check
make kind-namespace
make backend-kind-build  # only if localhost/joke-app:0.1.1 is not already built
make backend-kind-load
make backend-kind-deploy
make minihealth-kind-deploy
```

The profile overrides only the cluster and namespace; the existing loader
reads the shared `env` first. The Minihealth deploy and forward commands
select this profile by default. The frontend Service is internal to the
cluster; NGINX forwards the three `/api/` routes to the `joke-app` Service
in the same namespace.

## Troubleshooting

- **Connection refused:** keep the forward running. If port 8083 is busy,
  set `MINIHEALTH_PORT=8084` on both the forward and check commands and
  open `http://127.0.0.1:8084`.
- **An API card fails:** run
  `kubectl --context kind-test-0 -n base-back-front get deploy,pods,svc`
  and check that both Deployments have a ready replica.

For the workflow and its success/failure signals, run
`make minihealth-kind-explanation`, `just minihealth-kind-explanation`, or
`mise run minihealth:kind:explanation`. Use the same Make target names with
Just, or the corresponding `minihealth:kind:{deploy,forward,check}` mise tasks.
