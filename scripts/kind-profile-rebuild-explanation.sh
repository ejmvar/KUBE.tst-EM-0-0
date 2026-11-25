#!/usr/bin/env bash
cat <<'TEXT'
Objective: replace a disposable kind lab and prove that an env profile selects
both the new cluster and its namespace without editing scripts or manifests.

1. Before deletion, verify that the old lab is the disposable em-tst-00.
   Success: kind lists that cluster and its kubeconfig context is kind-em-tst-00.
   Failure: a missing or unexpected target means stop and inspect inventory.
2. Unset PROJECT_ENV_FILE and CLUSTER_NAME, then run mise run kind:down.
   Success: em-tst-00 disappears from kind and its context is removed.
   Failure: stop before creating the replacement; investigate the runtime.
   This removes the old cluster, workloads and cluster-local storage.
3. Export PROJECT_ENV_FILE=env.em-test-0-0.my-dev-0-0-0.
   Run mise run kind:up, then mise run kind:check.
   Success: context kind-em-test-0-0 responds and its node is Ready.
   Failure: inspect provider, image pull, and kubeconfig before proceeding.
4. Run mise run kind:namespace.
   Success: namespace my-dev-0-0-0 is Active. Rerunning is safe.
   Failure: check the selected profile and API access.

Run locally first. For Acer, stage with mise run kind:phase0:stage-acer,
then SSH into the printed directory and repeat the same steps after
confirming the old target on that host. See docs/kind-profile-rebuild.md.
Make and Just targets are kind-down, kind-up, kind-check, and kind-namespace.
TEXT
