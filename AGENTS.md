# Repository guide

- Read `CONSTITUTION.md` before planning or reviewing infrastructure changes. Start with kind, add one service at a time, and test each stage. The backend, frontend, database, and storage are roadmap items, not existing packages.
- `mise.toml` lists the Kubernetes tools, but its environment also sources user-local credential scripts and expects `.venv`. Use installed binaries directly for focused checks; neither Python nor ESP-IDF is required by the cluster scripts.

## Local cluster

- With `kind` and a running container runtime, create the cluster with `bash 000-kind-create-cluster.sh`. Its kind name is `em-tst-00`; its kubectl context is `kind-em-tst-00`. Check it explicitly with `kubectl cluster-info --context kind-em-tst-00`.
- For intentional teardown, use `kind delete cluster --name em-tst-00`. `000-kind-delete-cluster.sh` currently passes the kubectl context instead of the kind cluster name.
- For a syntax-only check without touching a cluster, run `bash -n 000-kind-create-cluster.sh && bash -n 000-kind-delete-cluster.sh`. No test suite is configured yet.


## Tooling
always keep necessary scripts and helpers in:
- ./scripts/ folder : to ensure simple repeatable execution
- makefile: also add help entry to simplify onboarding for users, developers, deployers, etc
- just : same objective
- mise task : under ./mise/

