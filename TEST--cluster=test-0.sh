#!/bin/bash

CLUSTER_NAME=test-0 PHASE1_PORT=8084 make kind-phase1-forward
# Then test http://127.0.0.1:8084/.
# If the forward starts but curl still fails,
# check the workloads with :
CLUSTER_NAME=test-0 make kind-phase1-check.


curl http://127.0.0.1:8084/

CLUSTER_NAME=test-0 make kind-phase0-check
m=$(cat<<LLLL
❯ CLUSTER_NAME=test-0 make kind-phase0-check
mise run kind:phase0:check
[kind:phase0:check] $ bash scripts/kind-phase0.sh check
using podman due to KIND_EXPERIMENTAL_PROVIDER
enabling experimental podman provider
em-test-0-0
test-0
Kubernetes control plane is running at https://127.0.0.1:40231
CoreDNS is running at https://127.0.0.1:40231/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
node/test-0-control-plane condition met

LLLL
)
kubectl cluster-info dump
