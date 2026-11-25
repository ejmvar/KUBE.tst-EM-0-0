# Release the backend to local kind

Run `make backend-kind-explanation`, `just backend-kind-explanation`, or
`mise run backend:kind:explanation` for the order and expected results.
Use a ready `em-tst-00` cluster and run these commands on its host.

Edit `BACKEND_VERSION` in the root `env` file before a new build. The file
also holds the cluster, provider, namespace, image name, ports and timeouts.
It is sourced as Bash: keep it trusted, non-secret, and portable.

```bash
mise run backend:kind:build
mise run backend:kind:load
mise run backend:kind:deploy
```

For an update, choose a new stable SemVer, run `build` and `load` again, then
run `mise run backend:kind:rollout` instead of `deploy`. The scripts never
overwrite an existing local tag. Keep old images if you need to roll back.
This version is the local image release tag, not the Python package version.
Builds default to Podman; use `KIND_EXPERIMENTAL_PROVIDER=docker` consistently
for a one-off Docker-backed run, or change `KIND_EXPERIMENTAL_PROVIDER` in `env`.
An explicitly set shell variable overrides the corresponding file default.

`CLUSTER_NAME` selects the kind cluster and derives its `kind-` kubeconfig
context. `BACKEND_NAMESPACE` separates workloads inside that cluster. Use
namespaces for additional app environments that can share the same nodes and
control plane; use a separate cluster when those must be isolated too.
See the [cluster and namespace naming rules](../CONSTITUTION.md#cluster-and-namespace-naming)
before creating a rolling or exact-release namespace. The current
`backend-lab` is a stable sandbox for in-place rollouts.

`kind load image-archive` imports the image into each node's local store.
`localhost/joke-app` is an image name here, not an HTTP registry. The
Deployment uses `imagePullPolicy: Never` and checks `/health` for readiness.
All changes target only the `backend-lab` namespace in `kind-em-tst-00`.

Verify the endpoints from another terminal while the forward is running:

```bash
# Terminal 1
mise run backend:kind:forward
# Terminal 2
BACKEND_PORT=8082 mise run backend:local:check
```

Stop the forward with Ctrl-C. The local development server on 8080 is
unaffected. Make and Just offer `backend-kind-build`, `backend-kind-load`,
`backend-kind-deploy`, `backend-kind-rollout`, and `backend-kind-forward`.
