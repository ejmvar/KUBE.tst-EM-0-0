#!/bin/bash

source env

kind get clusters
kind get nodes
kind get nodes --name XXX

kind create cluster --config kind_cluster_em-demo-0-0-0_30080.yml --wait 120s

kind get clusters
kind get nodes --name em-demo-0-0-0

m=$(
  cat <<LLLL

❯ kind create cluster --config kind_cluster_em-demo-0-0-0_30080.yml --wait 120s
enabling experimental podman provider
Creating cluster "em-demo-0-0-0" ...
 ✓ Ensuring node image (kindest/node:v1.37.0) 🖼️ 
 ✓ Preparing nodes 📦 📦 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
 ✓ Joining worker nodes 🚜 
 ✓ Waiting ≤ 2m0s for control-plane = Ready ⏳ 
 • Ready after 8s 💚
Set kubectl context to "kind-em-demo-0-0-0"
You can now use your cluster with:

kubectl cluster-info --context kind-em-demo-0-0-0

Not sure what to do next? 😅  Check out https://kind.sigs.k8s.io/docs/user/quick-start/


Have a question, bug, or feature request? Let us know! https://kind.sigs.k8s.io/#community 🙂


LLLL
)
