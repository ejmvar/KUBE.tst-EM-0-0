#!/bin/bash

set -a
source ./env
set +a

# ==============================
vars=(
  K_CLUSTER_MANAGER
  KIND_EXPERIMENTAL_PROVIDER
  K_CREATE_WAIT
  K_READY_WAIT
  K_ROLLOUT_WAIT
  CLUSTER_NAME
  BACKEND_VERSION
  BACKEND_IMAGE
  BACKEND_NAMESPACE
  BACKEND_LOCAL_PORT
  BACKEND_FORWARD_PORT
)

for v in "${vars[@]}"; do
  printf "##- %-30s : %s\n" "$v" "${!v}"
done
# ==============================

echo "============================================================"
#kind get clusters -q
# echo "#e- CLUSTER_NAME : $(kind get clusters -q)"
printf "#p- CLUSTER_NAME : $(kind get clusters -q)\n"

cmds=(
  # kind get clusters -q
"kind get clusters -q"
"kubectl cluster-info --context kind-k137"
"kubectl get nodes -o wide"
"kubectl get pods -A"
"kubectl get storageclass"
"kubectl version"
)

#for c in "${cmds[@]}"; do
for cmd in "${cmds[@]}"; do
    #printf "!- %-42s :\n%s\n" "$cmd" "$(eval "$cmd" 2>&1)"
    printf "-0 " "$cmd"
    # echo   "-1 " $cmd
    $cmd
    #printf "!- %-42s :\n%s\n" "$cmd" "$(eval "$cmd" 2>&1)"
done
# ==============================
