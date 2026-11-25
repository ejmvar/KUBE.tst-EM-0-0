
# Objectives:

Design the simplest kubernetes infrastrucure.
Ensure migration to new version (rollout, rollback)
Ensure proper scaling
Ensure observability
Verify namespace isolation
Verify inter-communication between services, clients, storage.


Ensure all basic services available from the very beginning [Services](./Services to implement).


# Tooling: from simplest environment to high availability
Start using :
- kind (start simple on-premise, plan for minikube, suggest alternative for huge clients, AWS, GCP, Azure)
- kubernetes
Gradually add:
- gateway-api (envoy, suggest others)
- loadbalancer (keda, review metaLB, research for alternatives: simpler, faster, wider applicability)

- devcontainer: plan for isolation

- plan for other kubernetes tooling


# Services to implement
these are the steps to enhance, step by step, so to verify every available service and interaction.
every stage of development must add testing (TDD always)

## Initial:
- backend: python (start minimal)
## add frontend
- frontend: react (start minimal)
## add database
- postgres for backend:
  -- read the smallest table
  -- return a value to backend
  -- expose in /api/testpg
## add secrets:
- spc name (space name to retain isolated environments)
- env name 
- rls name 
- client name 

## add block storage:
- ensure isolation between env ironments
- ensure backup facility 
- ensure recoverability


## add object storage: rustfs (s3 compatible)
- same as block storage

# Structure:

## Cluster and namespace naming

- Keep `CLUSTER_NAME` stable and independent of the project, environment, and
  application version. Use namespaces for workloads that can share the same
  nodes and control plane. Use a separate cluster when those must be isolated.
- Name future release namespaces `<project>-<environment>-<major>-<minor>-<patch>`.
  The project code identifies the project or client (for example, `em` or
  `nvt`). The environment is one of `demo`, `tst`, `stg`, `qa`, or `prd`.
  The final three numeric components are the deployed release's stable SemVer
  with hyphens replacing dots. For example, `em-demo-0-0-1` is `em` demo at
  `0.0.1`; `nvt-demo-0-0-3` is `nvt` demo at `0.0.3`.
- A release namespace represents one exact release. Do not deploy `0.0.2`
  into a namespace named for `0.0.1`. Deploy the new release alongside the
  old one and switch traffic separately when needed.
- Use rolling namespaces for long-lived client and evolving environments:
  - `<project>-<environment>-<major>` tracks one major version. For example,
    `em-prd-1` can roll from `1.2.0` to `1.3.0` in place, while `2.0.0`
    belongs in `em-prd-2`.
  - `<project>-<environment>` tracks an environment across major versions.
    For example, `nvt-stg` can move from `1.x` to `2.x` without a rename.
  - In both forms, record the exact deployed SemVer in the image tag.
- Names alone do not enforce isolation. Before sharing a cluster across
  clients, verify scoped RBAC and network policies, including a test that
  unintended cross-namespace traffic and secret access are blocked.
- Keep `backend-lab` as the existing rollout sandbox. The example release
  namespaces are reserved for future use; this convention does not create them.
