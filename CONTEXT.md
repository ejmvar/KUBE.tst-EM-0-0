# Kubernetes lab

Terms used to identify projects, environments, and deployments in the lab.

## Language

**Project code**:
The short identifier for a project or client, such as `em` or `nvt`.

**Environment**:
The intended use of a deployment: `demo`, `tst`, `stg`, `qa`, or `prd`.

**Release version**:
The stable `major.minor.patch` version of a deployed application, independent of the cluster name.

**Release namespace**:
A namespace representing one project, environment, and release version.

**Rolling namespace**:
A long-lived namespace for a project and environment, optionally scoped to a single major version.
