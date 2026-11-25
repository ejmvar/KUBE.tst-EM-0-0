# Replace the disposable kind lab with an env profile

Start with `make kind-profile-rebuild-explanation`,
`just kind-profile-rebuild-explanation`, or `mise run kind:profile-rebuild:explanation`.
Deleting a cluster removes its workloads and cluster-local storage. Inspect
the old target and back up anything needed before deleting it.

Run locally first. To repeat on Acer, run `make kind-phase0-stage-acer`
from the workstation, then `ssh acer` and enter the printed directory.
Use the same Podman account that owns the old cluster. Review the staged
configuration and run `mise trust` before using its tasks.

```bash
unset PROJECT_ENV_FILE CLUSTER_NAME BACKEND_NAMESPACE
KIND_EXPERIMENTAL_PROVIDER=podman mise exec -- kind get clusters
mise run kind:check
# Proceed only after confirming the intended old target is em-tst-00.
mise run kind:down
KIND_EXPERIMENTAL_PROVIDER=podman mise exec -- kind get clusters
mise exec -- kubectl config get-contexts
```

Confirm `em-tst-00` and `kind-em-tst-00` are gone, then run:

```bash
export PROJECT_ENV_FILE=env.em-test-0-0.my-dev-0-0-0
mise run kind:up
mise run kind:check
mise run kind:namespace
```

Expected: `kind-em-test-0-0` is reachable, its node is Ready, and
`my-dev-0-0-0` is Active. This does not deploy the backend. Make and Just
expose `kind-down`, `kind-up`, `kind-check`, and `kind-namespace`.

The root `env` supplies defaults, the selected `env.*` file overrides them,
and explicitly set process variables take precedence. Keep both files
trusted and free of secrets. The `dev` environment here is a disposable
parameterization example, not an addition to the standard release names.

## Verified results

| Host | Old cluster and context | New cluster | Namespace |
| --- | --- | --- | --- |
| Local Linux Mint | Removed | Ready in 16 seconds | Active on both runs |
| Acer bare-metal Linux Mint | Removed | Ready in 17 seconds | Active on both runs |

Both runs used Podman and the pinned kind node image. They did not test
fresh OS setup, deploy the backend, or validate namespace isolation.
