# Phase 0: Reproduce the kind lab on a clean Linux Mint host

**Goal:** create, check, and remove the single-node `em-tst-00` cluster using
mise, without copying a kubeconfig, workstation settings, or credentials.
This passed locally on Mint with Podman. The existing cluster on `acer` was
also verified over SSH; a full cold create → check → delete run there is
not yet recorded. This phase does not deploy the app or install K3s.

## 1. Get the files onto `acer`

Print the step order, success and failure signals, and side effects first:
`make kind-phase0-explanation`, `just kind-phase0-explanation`, or
`mise run kind:phase0:explanation`.

Run these from the workstation. The examples assume `acer` is an SSH host
alias; otherwise substitute `your-user@acer` or the correct hostname. On
first connection, verify the server's host-key fingerprint independently.

**For the current, uncommitted state**, run from this repository's root:

```bash
make kind-phase0-stage-acer
ssh -t acer
```

This transfers only the files needed for the test, not `.git`, `env`,
`mise.workstation.toml`, or local credentials. Use the printed `cd` command
in the SSH session.

**For a future repeat**, skip the archive and open `ssh -t acer`, then clone
the repository after installing the prerequisites in step 2:

```bash
git clone <repository-url> kind-phase0
cd kind-phase0
git switch --detach <phase-0-commit>
git rev-parse HEAD
```

Replace both placeholders before running the commands. For a private
repository, use the account's usual access rather than copying credentials.

## 2. Prepare the Mint host

Run on `acer` as the user who will run the test. Use `sudo` for package
installation only. The host needs outbound access to install mise, download
the pinned tools, and pull the kind node image.

```bash
hostname
cat /etc/os-release
uname -m

sudo apt update
sudo apt install -y ca-certificates curl git podman uidmap

# Only if mise is not already installed; see https://mise.jdx.dev/installing-mise.html
curl -fsSL https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"

mise --version
podman --version
podman info --format 'rootless={{.Host.Security.Rootless}} cgroups={{.Host.CgroupsVersion}}'
```

Expect `rootless=true cgroups=v2`. If `podman info` fails, resolve the
[rootless Podman prerequisites](https://kind.sigs.k8s.io/docs/user/rootless/)
before continuing. If kind specifically reports a cgroup delegation error,
retry the `mise run kind:up` line below as
`systemd-run --user --scope -p Delegate=yes mise run kind:up`.
No inbound Kubernetes port or SSH port forwarding is needed.

## 3. Run the smoke test on `acer`

Run from the lab directory. Review the mise configuration before trusting
it. The smoke task uses a temporary kubeconfig, refuses an existing
`em-tst-00` in the selected runtime, and deletes only a cluster it created.

```bash
mise trust
mise run kind:phase0:preflight
mise run kind:phase0:install-tools
mise run kind:phase0:smoke
```

On the current Acer account use `mise run kind:phase0:check` instead of
`smoke` to verify the existing cluster without altering it. To test fresh
creation and teardown, use a disposable environment. Each action is also
available through Make and Just with hyphens in place of colons.

**Pass criteria:** kind reports `v0.33.0`, kubectl reports `v1.37.1`,
`kind:check` reports the control plane running and
`node/em-tst-00-control-plane condition met`, and `kind:down` reports the
test node deleted. The node image is Kubernetes `v1.37.0`, pinned by digest
in `kind-lab.yaml`. Keep the terminal output with the host OS and tool
versions. Type `exit` to leave SSH.

On a cold machine, `kind:up` may need to pull the node image. If the pull
fails, check network access and registry errors before retrying. If
creation fails, inspect `mise exec -- kind get clusters` with
`KIND_EXPERIMENTAL_PROVIDER=podman` before retrying or cleaning up. Do not
delete a cluster you did not create for this test.

## Optional: evaluate Kiri on `acer`

Keep rootless Podman as the baseline. [Kiri's published comparison](https://runkiri.com/podman-alternative/)
does not include a Podman benchmark, so there is no evidence yet that it lowers
total host load on Mint. Test only after completing the Podman run above.

1. Review the [Kiri Linux installation notes](https://docs.runkiri.com/linux/).
   On a dedicated lab host, evaluate `kiri-lite` with a real Docker CLI (not
   a Podman alias). Kiri runs a root-owned service, and access to its socket
   is root-equivalent. Do not grant access just to run this comparison
   without the host owner's approval.
2. With Kiri approved and installed, run the same checks against its
   explicit socket. Confirm `docker version` identifies Kiri before
   proceeding to the smoke test:

   ```bash
   (
     unset DOCKER_CONTEXT
     export KIND_EXPERIMENTAL_PROVIDER=docker
     export DOCKER_HOST=unix:///run/kiri/docker.sock
     mise run kind:phase0:preflight
   )
   # After confirming the server above:
   env -u DOCKER_CONTEXT KIND_EXPERIMENTAL_PROVIDER=docker \
     DOCKER_HOST=unix:///run/kiri/docker.sock mise run kind:phase0:smoke
   ```

   Confirm the server is Kiri before continuing. This scopes the engine
   selection to the test instead of switching the default Docker context.
   Use the same pinned kind image and the same readiness and teardown
   checks. Do not use `kiri k8s start`: that starts K3s, not the kind lab.
3. Run one engine at a time without unrelated workloads. Record whole-host
   RAM and CPU before startup and after five minutes with the cluster Ready,
   plus peak RAM during startup and time to Ready. Repeat three warm-cache
   runs per engine; record cold pulls separately. Compare the Ready-state
   host load, not just daemon memory or container startup time.

Keep Podman unless Kiri passes the same checks and consistently lowers host
load enough to justify the change from rootless Podman to a root-owned service.
Kiri compatibility and resource savings on `acer` are not yet verified.

## What was run on the original Mint machine

| Check | Command or procedure | Observed result |
|---|---|---|
| Tool and runtime inventory | `kind version`, `kubectl version --client`, `mise --version`, `docker info --format '{{.ServerVersion}}'`, `podman info --format '{{.Host.CgroupsVersion}}'` | kind `v0.33.0`, kubectl `v1.37.1`, mise `2026.10.23`; the Docker-format query failed; Podman reported `v2`. |
| Podman preflight | `KIND_EXPERIMENTAL_PROVIDER=podman kind get clusters`; `podman image exists` with the pinned digest from `kind-lab.yaml` | An unrelated cluster named `kind` existed; `em-tst-00` did not. The pinned image was already cached. |
| Test and lint | `bash scripts/test-kind-lab.sh`; `bash -n` on both new scripts; `shellcheck scripts/kind-lab.sh scripts/test-kind-lab.sh`; `git diff --check` | The routing test first failed because the implementation did not exist, then passed. Syntax, lint, and whitespace checks passed. |
| Task discovery | `mise config ls`, `mise tasks ls` with temporary config; `make help`; `just --list`; `make -n kind-up kind-check kind-down`; `just --dry-run kind-up kind-check kind-down` | Passed after correcting the mise task-file syntax and the Justfile parse error. Both wrappers resolve to the same mise commands. |
| Live lifecycle | `mise run kind:up`, `mise run kind:check`, `mise run kind:down` with isolated mise config, temporary kubeconfig, and the Podman provider | Passed. API reachable, node Ready, test node deleted. The original machine already had the pinned CLI binaries and image, so this did not prove fresh downloads. |
| Repository review | `gentle-ai review mode status`; `gentle-ai review assess --cwd "$PWD" --agent claude-code --json` | Review mode was on; assessment did not complete because the worktree contained undeclared untracked files. Not a lab prerequisite. |

The live commands call `kind create cluster --name em-tst-00 --config
kind-lab.yaml --wait 120s`, then `kubectl --context kind-em-tst-00 cluster-info`
and `kubectl --context kind-em-tst-00 wait --for=condition=Ready nodes --all
--timeout=60s`, and finally `kind delete cluster --name em-tst-00`. The script
uses an absolute path to the config so it also works outside the repo root.

## Verification on `acer`

On 2026-11-25, read-only SSH checks confirmed that Podman-backed kind lists
`em-tst-00`, the API responds in context `kind-em-tst-00`, and
`em-tst-00-control-plane` is `Ready` on Kubernetes `v1.37.0`. No cluster was
created, changed, or deleted during this check.

To recheck an existing cluster, connect with `ssh acer` and run:

```bash
KIND_EXPERIMENTAL_PROVIDER=podman kind get clusters
kubectl --context kind-em-tst-00 --request-timeout=10s cluster-info
kubectl --context kind-em-tst-00 --request-timeout=10s get nodes
```

**Phase exit:** the second-host readiness check passed. Record a cold run
in a separate disposable environment to prove fresh setup and teardown
without touching the existing cluster.
