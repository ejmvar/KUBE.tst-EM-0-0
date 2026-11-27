# Local Kubernetes lab

For a new Linux Mint host, follow the [Phase 0 runbook](docs/phase-0-kind-lab.md).
It includes the commands to repeat the smoke test over SSH on `acer`.
Once kind is ready, follow [Phase 1: deploy Flask and Minihealth in two namespaces](docs/phase-1-kind-app.md).
For the next step, compare [Phase 2 DNS and access options](docs/phase-2-dns-options.md).
Use the [Phase 2 Tailscale runbook](docs/phase-2-tailscale.md) for private access by machine name.
To replace a disposable cluster and create a namespace from a separate
configuration profile, see the [kind profile rebuild runbook](docs/kind-profile-rebuild.md).

Start with `make kind-phase0-explanation` or
`make backend-smoke-acer-explanation` for the step order and expected
results. Both explanations are also available through Just and mise. See
the [backend smoke runbook](docs/backend-smoke-acer.md) for its workflow.

For fast iteration without Kubernetes, see the
[local backend HTTP checks](docs/backend-local.md).

To deploy or update a version on kind, see the
[backend release workflow](docs/backend-kind.md).

On each Linux Mint machine, install mise and a supported, running container
runtime. Confirm the host uses cgroup v2. Docker is the simplest default;
to use Podman, set `KIND_EXPERIMENTAL_PROVIDER=podman` consistently for
creation and teardown.

From a checkout:

```sh
mise trust
mise install
mise run kind:up
mise run kind:check
```

The lab is `em-tst-00`; its Kubernetes context is `kind-em-tst-00`.
It does not map application ports to the host or require Python or personal
credentials. Repeat the same commands on the second machine from a fresh
checkout without copying kubeconfig.

When you intend to remove the lab, run `mise run kind:down`. The Make and
Just aliases are `kind-up`, `kind-check`, and `kind-down`. The separate demo
cluster commands are unchanged; use the mise tasks for this lab rather than
the legacy root scripts. To use the previous personal tool setup on a
configured workstation, pass `--env workstation` to mise.

Run `bash scripts/test-kind-lab.sh` to test command routing without a cluster.
