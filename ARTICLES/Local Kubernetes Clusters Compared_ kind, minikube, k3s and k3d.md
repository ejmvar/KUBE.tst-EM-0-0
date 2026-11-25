---
title: "Local Kubernetes Clusters Compared: kind, minikube, k3s and k3d"
source: "https://kubezilla.io/local-kubernetes-clusters-compared-kind-minikube-k3s-k3d/"
author:
  - "[[Kubezilla Team]]"
published: 2026-11-18
created: 2026-11-20
description: "kind, minikube, k3s and k3d all give you Kubernetes on your own machine, but they work in different ways. This guide compares them and shows the official commands to get started with each."
tags:
  - "clippings"
---
![Terminal style banner reading Local Kubernetes Clusters Compared: kind, minikube, k3s and k3d](https://kubezilla.io/wp-content/uploads/2026/11/local-kubernetes-clusters-compared.webp)

Terminal style banner reading Local Kubernetes Clusters Compared: kind, minikube, k3s and k3d

Almost every Kubernetes journey starts on a laptop. Before you touch a managed cloud cluster, you need a safe place to break things, test manifests, try a Helm chart or run a controller you are writing. That place is a local cluster. The good news is that you have several solid, free options. The less good news is that they look similar at first glance, and picking the wrong one can cost you time later.

This guide compares the four local cluster tools you will meet most often: **kind**, **minikube**, **k3s** and **k3d**. We explain how each one works, what it is best at, and show the official commands to get a cluster running. If you are just starting out, pair this post with our [Kubernetes learning path for 2026](https://kubezilla.io/kubernetes-learning-path-2026-first-cluster-to-production/).

## Why the choice of local cluster matters

All four tools give you a working Kubernetes API that `kubectl` can talk to. The differences show up in the details: how fast a cluster starts, how many nodes you can simulate, how you get your locally built images into the cluster, and how close the setup is to what you run in production.

A few questions help narrow things down:

- Do you want to **learn Kubernetes** with friendly extras like a dashboard and add ons, or do you want a **throwaway cluster for tests and CI**?
- Do you need **multiple nodes** to try scheduling rules, taints or node failures?
- Are you running on a laptop with Docker, or on a **real Linux machine**, a Raspberry Pi or an edge device?
- Do you need to test against a **specific Kubernetes version**?

Keep your answers in mind as you read the sections below.

## kind: Kubernetes in Docker

kind runs local Kubernetes clusters using Docker containers as nodes. Each node container is bootstrapped with kubeadm, the same tool many teams use to build real clusters. The project lives under Kubernetes SIGs and its docs say it was primarily designed for testing Kubernetes itself, while also being a good fit for local development and CI. The kind website also describes it as a CNCF certified conformant Kubernetes installer.

Things kind does well:

- **Speed and cleanup.** Clusters are just containers, so creating and deleting them is quick, and deleting leaves little behind.
- **Multi node and HA layouts.** A small YAML file gives you several control plane or worker nodes.
- **CI pipelines.** Because it only needs a container runtime, kind is a common choice for running integration tests in CI jobs.
- **Runtime choice.** Besides Docker, kind can use podman or nerdctl, though those run rootless by default and need extra setup.

Where it is less friendly: kind is deliberately minimal. There is no built in dashboard or add on system, so you install things like an ingress controller yourself.

## minikube: the learning friendly classic

minikube describes itself as local Kubernetes focused on making it easy to learn and develop for Kubernetes. It is also the tool used in several official Kubernetes tutorials, such as Hello Minikube on kubernetes.io. minikube can run the cluster inside a container (Docker or Podman) or inside a virtual machine using drivers such as QEMU, Hyper-V, KVM, Parallels, VirtualBox or VMware.

Things minikube does well:

- **Add ons.** `minikube addons list` shows optional components, and one command enables things like an ingress controller.
- **A built in dashboard.** `minikube dashboard` opens the Kubernetes Dashboard for you.
- **Driver flexibility.** If you need a VM instead of a container, for example to test kernel level features, minikube supports that.
- **Multiple profiles and nodes.** You can run more than one cluster with profiles, and start multi node clusters with `--nodes`.

The official start guide lists the minimum requirements as 2 CPUs, 2GB of free memory, 20GB of free disk space, an internet connection and a container or VM manager. For a deeper walk through, see our [minikube tutorial](https://kubezilla.io/minikube-tutorial-complete-guide-to-running-kubernetes-locally/).

## k3s and k3d: lightweight Kubernetes, on metal or in Docker

### k3s

k3s is a lightweight, fully compliant Kubernetes distribution. It is a CNCF Sandbox project, accepted in August 2020. Its docs describe a single binary under 100 MB, minimal external dependencies (a modern kernel and cgroup mounts) and use cases such as edge, homelabs, IoT, CI, development, ARM single board computers and air gapped environments.

k3s is batteries included. Out of the box it bundles containerd, Flannel for networking, CoreDNS, Traefik as the ingress controller, ServiceLB, Kube-router for network policy, the local path provisioner for persistent volumes and Spegel as a registry mirror. Its default datastore is SQLite, with etcd, MySQL and PostgreSQL also supported. A single server install gives you a complete cluster, and you can add agent nodes later.

k3s is not a Docker based tool. You install it directly on a Linux host or VM. That makes it a great fit when your “local” cluster is a spare machine, a Raspberry Pi or a small lab, and it is also a real option for production at the edge.

### k3d

k3d is a small tool that runs k3s inside Docker. It gives you the speed and disposability of kind, but with the k3s distribution and its bundled components. The k3d docs note that it is a community driven project and not an official Rancher (SUSE) product. You can create single node or multi node clusters, choose the number of servers and agents, and map ports from the cluster to your host.

## Side by side comparison

- **How nodes run.** kind: Docker, podman or nerdctl containers. minikube: a container or a VM, depending on the driver. k3s: directly on a Linux host or VM. k3d: k3s nodes as Docker containers.
- **Kubernetes flavor.** kind and minikube run upstream Kubernetes. k3s and k3d run the k3s distribution, which is conformant but ships its own defaults such as Traefik and Flannel.
- **Multi node.** All four support it: a kind config file, `minikube start --nodes`, k3s agents joined with a token, or `k3d cluster create --agents`.
- **Extras out of the box.** minikube has add ons and a dashboard. k3s and k3d include ingress, a load balancer and storage. kind keeps the defaults minimal.
- **Best fit.** kind for CI and testing controllers or Kubernetes versions. minikube for learning and feature exploration. k3s for real hardware, edge and homelabs. k3d for fast local clusters that mirror a k3s setup.

No tool is “best” in general. Many teams use two: minikube or k3d for day to day work, and kind in CI. Whatever you pick, keep the cluster version in line with what you run in production, and read our guide to the [Kubernetes release cycle and version skew](https://kubezilla.io/kubernetes-release-cycle-upgrades-version-skew-explained/) to understand how versions relate.

## Hands on: create a cluster with each tool

The commands below come from each project’s official docs. **Prerequisites:** for kind, minikube and k3d you need a container runtime such as Docker installed and running, plus `kubectl`. For k3s you need a Linux machine or VM where you can run commands with root privileges.

### kind

Install with Homebrew (other options, including `go install`, are in the kind quick start), then create and delete a cluster:

```js
brew install kind
kind create cluster
kubectl cluster-info --context kind-kind
kind delete cluster
```

For a three node cluster with two workers, save this as a config file and pass it with `kind create cluster --config`:

```js
# three node (two workers) cluster config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
```

To use an image you built locally without pushing it to a registry:

```js
kind load docker-image my-app:latest
```

### minikube

```js
minikube start
kubectl get po -A
minikube addons enable ingress
minikube dashboard
```

For a two node cluster in its own profile, and to load a local image:

```js
minikube start --nodes 2 -p multinode-demo
kubectl get nodes
minikube image load my_image
```

When you are done, `minikube stop` halts the cluster and `minikube delete --all` removes all minikube clusters.

### k3s

On the Linux server node, the official install script sets up k3s as a service. The kubeconfig is written to `/etc/rancher/k3s/k3s.yaml`.

```js
curl -sfL https://get.k3s.io | sh -
```

To join another machine as an agent, read the token from `/var/lib/rancher/k3s/server/node-token` on the server and run this on the new node, replacing the URL and token with your own values:

```js
curl -sfL https://get.k3s.io | K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -
```

### k3d

```js
brew install k3d
k3d cluster create mycluster
```

A cluster with two agents and host port mappings, plus importing a local image into a named cluster:

```js
k3d cluster create --agents 2 -p 8080:80@agent:0 -p 8081@agent:1
k3d image import my-app:latest -c mycluster
```

Once any of these clusters is up, try deploying the resources from our [Kubernetes workloads guide](https://kubezilla.io/kubernetes-workloads-explained-deployments-statefulsets-daemonsets-jobs-cronjobs/) to see how Deployments and StatefulSets behave across nodes.

## Tips for a smooth local setup

- **Watch your kubectl context.** Each tool adds its own context (kind uses `kind-<cluster-name>`). Run `kubectl config current-context` before applying anything, so you never deploy to the wrong cluster.
- **Give Docker enough resources.** On macOS and Windows, the Docker VM limits what your nodes can use. kind’s docs, for example, recommend 8GB of RAM for the Docker VM when building node images.
- **Skip the registry for inner loop work.** Use `kind load docker-image`, `minikube image load` or `k3d image import` to move images straight into the cluster.
- **Treat clusters as disposable.** Keep your manifests, Helm values or Kustomize overlays in Git, so you can delete and recreate a cluster in a minute.
- **Remember the differences from production.** Local clusters lack cloud load balancers, real storage classes and cloud IAM. Test those parts on a real staging cluster.

## Key takeaways

- kind runs upstream Kubernetes in containers and is a natural choice for CI and for testing controllers or specific Kubernetes versions.
- minikube is the most learning friendly option, with add ons, a dashboard and support for both container and VM drivers.
- k3s is a lightweight, conformant CNCF Sandbox distribution installed directly on Linux, well suited to edge devices, homelabs and small servers.
- k3d wraps k3s in Docker for fast, disposable local clusters with ingress and storage already included.
- All four support multi node clusters, and all four let you load local images without a registry.
- Pick based on your goal, keep versions aligned with production, and always check your kubectl context.

## Sources

Information in this guide comes from the official project documentation: [kind](https://kind.sigs.k8s.io/), [kind quick start](https://kind.sigs.k8s.io/docs/user/quick-start/), [minikube start](https://minikube.sigs.k8s.io/docs/start/), [minikube multi node tutorial](https://minikube.sigs.k8s.io/docs/tutorials/multi_node/), [minikube pushing images](https://minikube.sigs.k8s.io/docs/handbook/pushing/), [K3s docs](https://docs.k3s.io/), [K3s quick start](https://docs.k3s.io/quick-start), [K3s on cncf.io](https://www.cncf.io/projects/k3s/), [k3d docs](https://k3d.io/stable/), [k3d cluster create reference](https://k3d.io/stable/usage/commands/k3d_cluster_create/), [k3d image import reference](https://k3d.io/stable/usage/commands/k3d_image_import/), [Kubernetes install tools](https://kubernetes.io/docs/tasks/tools/).