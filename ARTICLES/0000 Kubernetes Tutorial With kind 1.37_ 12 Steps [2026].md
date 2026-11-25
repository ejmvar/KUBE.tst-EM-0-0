---
title: "Kubernetes Tutorial With kind 1.37: 12 Steps [2026]"
source: "https://shattered.io/kubernetes-tutorial-kind-1-37-local-cluster-12-steps-2026/"
author:
  - "[[Laura Bennett]]"
published: 2026-11-04
created: 2026-11-20
description: "Run Kubernetes 1.37 locally with kind v0.33.0 and kubectl 1.37.1. A Kubernetes tutorial with 12 steps, 11 fixes and a full working project."
tags:
  - "clippings"
---
## Kubernetes Tutorial With kind 1.37: 12 Steps, 75 Min \[2026\]

![Kubernetes Tutorial With kind 1.37: 12 Steps, 75 Min](https://shattered.io/wp-content/uploads/2026/11/kubernetes-tutorial-kind-1-37-local-cluster-12-steps-2026-gen.webp)

Kubernetes Tutorial With kind 1.37: 12 Steps, 75 Min

A kind cluster boots Kubernetes 1.37 on a laptop with one config file and one command. [kind v0.33.0](https://github.com/kubernetes-sigs/kind/releases/tag/v0.33.0) landed on August 26, 2026 and defaults to the kindest/node:v1.37.0 image, which makes it the fastest route to a real multi-node Kubernetes tutorial on the current release line.

The project below runs three nodes inside Docker containers, ships a small Python service through a Deployment, a Service, a ConfigMap, a Secret and a PersistentVolumeClaim, then pushes a rolling update and rolls it back. Anyone comfortable in a shell can finish it in one sitting. Readers who want the container-versus-orchestrator background first should skim [Kubernetes vs Docker](https://shattered.io/kubernetes-vs-docker-2026/) and come back.

Version discipline matters more than usual right now. The Kubernetes project lists 1.37.1 as the newest 1.37 patch, while kind’s default node image still points at 1.37.0. Every command below says which of the two it uses, so nothing in the cluster drifts from what you read here.

Don't miss new tech stories on Google

Add Shattered once in the Google app and our stories show up in your news suggestions.

## Why a Local Kubernetes 1.37 Cluster Beats a Cloud Sandbox for Learning

Kubernetes stopped being optional knowledge a while ago. The CNCF’s 2024 Cloud Native Survey found that 80% of organizations ran Kubernetes in production, up from 66% in 2023, and 93% were using, piloting or evaluating it. Those figures come from the [CNCF research announcement](https://www.cncf.io/announcements/2025/04/01/cncf-research-reveals-how-cloud-native-technology-is-reshaping-global-business-and-innovation/) on that survey.

Advertisement

A managed cloud cluster teaches the same objects but adds friction a beginner does not need. You wait for a control plane, you pay for idle nodes, and you risk leaving a load balancer running over a weekend. A local kind cluster costs nothing beyond CPU and RAM. It also dies and respawns in minutes, which turns every mistake into a cheap experiment instead of a billing event.

kind (Kubernetes in Docker) runs each Kubernetes node as a container. The Kubernetes documentation still recommends it as a local learning environment, and the project describes itself as a tool for running local clusters with Docker container nodes. Because the nodes are ordinary containers, you can run a control plane plus two workers on one machine and watch the scheduler spread pods between them. A single-node toy cluster hides that behavior completely.

Lighter distributions exist, and the right pick depends on what you want to learn. A comparison like [K3s vs K8s across six Kubernetes distros](https://shattered.io/k3s-vs-k8s-kubernetes-distributions-rke2-openshift-talos-2026/) shows where k3s, RKE2 and Talos make sense. For a first Kubernetes tutorial, kind has one advantage that matters: it runs upstream Kubernetes node images, so the API server you practice against matches what a cloud provider ships.

Teams that only need to schedule a handful of containers on a few hosts sometimes ask whether orchestration is overkill. Kubernetes versus Docker Swarm is a fair question for them. The short version: if the job listings in your market say Kubernetes, learn Kubernetes.

### What Kubernetes 1.37 “Garhwal” Brings

Kubernetes 1.37, codenamed Garhwal, shipped on August 26, 2026 with 67 enhancements: 16 stable, 23 beta, 27 alpha and one deprecation or removal. According to the release coverage, SELinuxMount and SELinuxChangePolicy graduated to stable and on by default, and gang scheduling reached beta through a Workload API and PodGroup concept. Dynamic Resource Allocation support for extended resources reportedly went generally available in a September 3 follow-up post.

None of those features changes how you write a Deployment, and that is the point of starting here. The objects used here behave the same on 1.35, 1.36 and 1.37, the three minor branches the project currently maintains. Learning on 1.37 simply means the cluster you build today will not fall out of support while you are still practicing on it.

## Prerequisites and Version Matrix

You need a Linux, macOS or Windows machine with a working container runtime and a terminal. Plan for at least 8 GB of RAM free for Docker. A three-node kind cluster plus a handful of pods runs comfortably there, and the kind documentation itself recommends 8 GB for the virtual machine behind Docker on macOS and Windows when building node images. A 4-core CPU keeps the control plane responsive while pods start.

| Component | Version to use | Why this version |
| --- | --- | --- |
| Kubernetes (node image) | kindest/node:v1.37.0 (kind default), 1.37.1 is the newest patch | kind v0.33.0 pins the 1.37.0 image by digest. Kubernetes lists 1.37.1 as the latest 1.37 patch. |
| kind | v0.33.0 | Current stable tagged release per the kind quick-start |
| kubectl | v1.37.1 (1.36 to 1.38 supported) | Client may differ from the API server by one minor version |
| Docker | Current Docker Engine or Docker Desktop | kind runs every node as a container |
| Python (inside the image) | python:3.13-slim base image | Standard library only, no pip step |
| Shell tools | bash or zsh, curl, openssl | Install scripts and secret generation |

Docker deserves one warning. Docker Desktop and Docker Engine carry separate version numbers, and neither one decides which Kubernetes version kind runs. The node image does. Docker also requires a paid Desktop subscription for commercial use in organizations with more than 250 employees or more than $10 million in annual revenue, according to its Desktop release notes. Docker reportedly keeps Desktop free for personal use and education. Linux users can skip Desktop entirely and install Docker Engine from their distribution’s repository.

kubectl’s skew rule explains the version row. The client supports a difference of one minor version in either direction from the API server. For a 1.37 cluster that means kubectl 1.36, 1.37 or 1.38 all work, and 1.37 is the simplest match. Anything older than 1.36 or newer than 1.38 sits outside the documented window. Anyone pointing these manifests at a shared 1.37 cluster at work should read the [Kubernetes 1.37 breaking changes](https://shattered.io/kubernetes-1-37-release-breaking-changes-2026/) first.

Check the host before installing anything. Kubernetes moved cgroup v1 into maintenance mode back in release 1.31, so cgroup v2 is the safe default on a Linux host. Run the two commands below. A result of `cgroup2fs` from the second one means you are ready. Docker Desktop on macOS and Windows handles this inside its own virtual machine.

```
docker version --format '{{.Server.Version}}'
stat -fc %T /sys/fs/cgroup/
```

The first command prints your Docker server version and proves the daemon answers. The second prints the cgroup filesystem type. If Docker reports a permission error, add your user to the docker group, log out, and log back in before moving on.

## Steps 1 to 3: Check Docker, Install kubectl 1.37.1 and kind v0.33.0

**Step 1: Confirm the container runtime works.** Run a throwaway container before you install any Kubernetes tooling. If this fails, nothing later will work, and the error messages from kind are far less readable than the ones from Docker itself.

```
docker run --rm hello-world
```

You should see a short greeting that starts with “Hello from Docker!” and ends with a description of the pipeline the daemon just ran. That message proves the client reached the daemon, the daemon pulled an image, and a container ran to completion.

**Step 2: Install kubectl at the cluster’s version.** Download the 1.37.1 binary directly from the Kubernetes release host, verify its checksum, and move it onto your PATH. Pinning the version in the URL beats a package manager here, because distribution repositories often lag the newest patch by weeks. The commands below target Linux on x86\_64. On Apple Silicon swap the path segment `linux/amd64` for `darwin/arm64`.

```
curl -LO "https://dl.k8s.io/release/v1.37.1/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/v1.37.1/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

The checksum line must print `kubectl: OK`. If it prints FAILED, delete both files and download again, because a truncated download is the usual cause. The final command should report a client version of v1.37.1. Windows users can fetch the same release with `curl.exe` and place the.exe file in a folder on their PATH.

**Step 3: Install kind v0.33.0.** The [kind quick-start](https://kind.sigs.k8s.io/docs/user/quick-start/%23loading-an-image-into-your-cluster) publishes direct download links for each platform and marks v0.33.0 as the current stable tagged release. It recommends stable releases for CI in particular. Use the architecture test from the docs so the same snippet works on Intel and ARM Linux machines.

```
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.33.0/kind-linux-amd64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.33.0/kind-linux-arm64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version
```

On macOS the same URLs use `kind-darwin-amd64` or `kind-darwin-arm64`. On Windows, `curl.exe -Lo kind-windows-amd64.exe` against the matching v0.33.0 URL does the job. Go users can run `go install sigs.k8s.io/kind@v0.33.0` instead. The version command prints a line like this:

```
kind v0.33.0 go1.xx linux/amd64
```

The Go toolchain string varies by build, so only the leading `kind v0.33.0` matters. Shell completion scripts can wait. Fewer moving parts make the first cluster easier to debug.

## Steps 4 to 6: Create a Three-Node kind Cluster on the 1.37 Node Image

**Step 4: Write the cluster config.** kind selects the Kubernetes version through the node image, so an unpinned config does not guarantee 1.37. Name the image on every node. The config below also publishes one port from the control-plane container to your laptop, which Step 10 uses to reach the app without port-forwarding. Save it as `kind-config.yaml`.

```
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: k137
nodes:
  - role: control-plane
    image: kindest/node:v1.37.0
    extraPortMappings:
      - containerPort: 30080
        hostPort: 8080
        listenAddress: "127.0.0.1"
        protocol: TCP
  - role: worker
    image: kindest/node:v1.37.0
  - role: worker
    image: kindest/node:v1.37.0
```

The kind documentation recommends appending the image’s SHA-256 digest (an `@sha256:` suffix) to each tag, copied from the v0.33.0 release notes, so the node image cannot change underneath you. Add it once you have the release page open. The release data confirms v1.37.0 as kind’s default image but does not confirm a published v1.37.1 node image, so check the release notes before you try to bump the tag. The listen address stays on 127.0.0.1 on purpose. The kind docs note that the default of 0.0.0.0 exposes the port to your whole network.

**Step 5: Create the cluster.** The `--wait` flag blocks until the control plane reports ready and takes durations such as 30s or 5m. Give it two minutes. The first run downloads the node image, so it takes longer than later runs.

```
kind create cluster --config kind-config.yaml --wait 120s
```

Healthy output looks like this, with the node image line showing the pinned tag:

```
Creating cluster "k137" ...
 ✓ Ensuring node image (kindest/node:v1.37.0)
 ✓ Preparing nodes
 ✓ Writing configuration
 ✓ Starting control-plane
 ✓ Installing CNI
 ✓ Installing StorageClass
 ✓ Joining worker nodes
 ✓ Waiting ≤ 2m0s for control-plane = Ready
Set kubectl context to "kind-k137"
You can now use your cluster with:

kubectl cluster-info --context kind-k137
```

kind writes a new context named `kind-k137` into your kubeconfig and switches to it. Note the “Installing StorageClass” line. That default class powers the PersistentVolumeClaim in Step 11.

Advertisement

**Step 6: Read the cluster before deploying anything.** Beginners skip this and then cannot tell a broken cluster from a broken manifest. Spend two minutes looking at what kind built.

```
kubectl cluster-info --context kind-k137
kubectl get nodes -o wide
kubectl get pods -A
kubectl get storageclass
kubectl version
```

The node listing should show three nodes in Ready status, each reporting a kubelet version of v1.37.0:

```
NAME                 STATUS   ROLES           AGE   VERSION   INTERNAL-IP
k137-control-plane   Ready    control-plane   95s   v1.37.0   172.18.0.4
k137-worker          Ready    <none>          80s   v1.37.0   172.18.0.2
k137-worker2         Ready    <none>          80s   v1.37.0   172.18.0.3
```

Ages and internal IPs differ on your machine. The pod listing across all namespaces should show CoreDNS, etcd, the API server, the controller manager, the scheduler, kube-proxy, kindnet and a local-path provisioner, all Running. If any sit in Pending or CrashLoopBackOff, jump to the troubleshooting table before continuing. The `kubectl version` output shows a client at v1.37.1 and a server at v1.37.0, a one-patch gap that causes no trouble. The two workers here are Docker containers you created by hand. In a cloud cluster, a node autoscaler such as the one in the [Karpenter on EKS tutorial](https://shattered.io/karpenter-eks-tutorial-nodepool-spot-consolidation-12-steps-2026/) adds and removes that capacity for you.

### Know the Default Networks

kind assigns pods the 10.244.0.0/16 range and services 10.96.0.0/16 by default for IPv4. Write those two numbers down. When a corporate VPN or home network already uses either range, routing breaks in ways that look like random timeouts. Both ranges can be overridden in the cluster config under `networking.podSubnet` and `networking.serviceSubnet`.

## Step 7: Build the Demo App and Load It Into the Cluster

A cluster with nothing to run teaches little, so the next piece is a tiny HTTP service written with the Python standard library. It exposes five endpoints: a root greeting, a liveness check, a readiness check that stays unready for a few seconds after boot, a config echo, and a visit counter that writes to disk. Those five cover every Kubernetes behavior the later steps demonstrate. Create a project folder with an `app` subfolder and save this as `app/app.py`.

```
import json
import os
import socket
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT = int(os.environ.get("PORT", "8000"))
GREETING = os.environ.get("GREETING", "hello")
DATA_FILE = os.environ.get("DATA_FILE", "/data/visits.txt")
API_TOKEN = os.environ.get("API_TOKEN", "")
VERSION = os.environ.get("APP_VERSION", "v1")
READY_AFTER = float(os.environ.get("READY_AFTER_SECONDS", "3"))
STARTED = time.time()
LOCK = threading.Lock()

def read_count():
    try:
        with open(DATA_FILE) as handle:
            return int(handle.read().strip() or 0)
    except (FileNotFoundError, ValueError):
        return 0

def bump():
    with LOCK:
        count = read_count() + 1
        os.makedirs(os.path.dirname(DATA_FILE), exist_ok=True)
        with open(DATA_FILE, "w") as handle:
            handle.write(str(count))
        return count

class Handler(BaseHTTPRequestHandler):
    def reply(self, code, body):
        data = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path == "/healthz":
            return self.reply(200, {"status": "alive"})
        if self.path == "/readyz":
            ready = time.time() - STARTED >= READY_AFTER
            return self.reply(200 if ready else 503, {"ready": ready})
        if self.path == "/hit":
            return self.reply(200, {"pod": socket.gethostname(), "visits": bump()})
        if self.path == "/config":
            return self.reply(200, {"greeting": GREETING, "token_configured": bool(API_TOKEN), "version": VERSION})
        return self.reply(200, {"message": GREETING, "pod": socket.gethostname(), "version": VERSION})

    def log_message(self, fmt, *args):
        print(fmt % args, flush=True)

if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
```

The service never prints the token. It only reports whether one is configured, which keeps secrets out of logs and out of curl output. Now the Dockerfile, saved as `app/Dockerfile`. It runs as a non-root user with a fixed numeric ID, which the Deployment in Step 9 will enforce.

```
FROM python:3.13-slim
ARG APP_VERSION=v1
ENV APP_VERSION=$APP_VERSION PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1
WORKDIR /app
COPY app.py .
RUN useradd --uid 10001 --no-create-home appuser
USER 10001
EXPOSE 8000
CMD ["python", "app.py"]
```

Build version one, smoke-test it in plain Docker, and then copy it into the cluster. A kind node cannot see your laptop’s local image cache. It has its own container runtime, so the image has to travel into each node explicitly. The `kind load docker-image` command does that for all three nodes at once.

```
docker build --build-arg APP_VERSION=v1 -t demo-web:v1 app/
docker run --rm -d --name smoke -p 8000:8000 demo-web:v1
curl -s http://127.0.0.1:8000/
docker stop smoke
kind load docker-image demo-web:v1 --name k137
docker exec k137-worker crictl images | grep demo-web
```

The curl call returns a JSON object with the greeting “hello”, the container ID as the pod name, and version v1. The last command lists the image inside the worker node’s runtime, proof the load worked:

```
docker.io/library/demo-web   v1   3f1c2a9d7b64   58.3MB
```

Your image ID and size will differ. Two rules save hours of confusion here. Never tag the image `latest`, because Kubernetes then defaults to pulling from a registry on every start and fails. And always use a new tag for every build, because reloading a changed image under an old tag leaves running pods untouched.

## Step 8: Create a Namespace, a ConfigMap, and a Secret

Namespaces fence a project off from everything else in the cluster. Putting your work in its own namespace means one command deletes it all, and it stops you from cluttering `default`. Save the file below as `k8s/00-namespace.yaml` and the ConfigMap as `k8s/10-configmap.yaml`. The numeric prefixes make a directory-wide apply run in a sensible order.

```
apiVersion: v1
kind: Namespace
metadata:
  name: tutorial
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-config
  namespace: tutorial
data:
  GREETING: "hello from Kubernetes 1.37"
  READY_AFTER_SECONDS: "5"
```

Keep the two documents in separate files in your own copy, or split them with the `---` marker as shown. Either style works with `kubectl apply`. The ConfigMap holds non-sensitive settings. Anything sensitive goes in a Secret, and the Secret should never land in a file you commit. Create it from the command line instead.

```
kubectl apply -f k8s/00-namespace.yaml
kubectl -n tutorial create secret generic web-secret \
  --from-literal=api-token="$(openssl rand -hex 16)"
kubectl -n tutorial get configmap,secret
```

The listing confirms both objects exist:

```
NAME                   DATA   AGE
configmap/web-config   2      4s

NAME                TYPE     DATA   AGE
secret/web-secret   Opaque   1      3s
```

A common misconception deserves a direct correction. Kubernetes stores Secret values as base64, and base64 is an encoding, not encryption. Run `kubectl -n tutorial get secret web-secret -o yaml` and anyone with read access can decode the token with one pipe to `base64 -d`. Real protection comes from RBAC limits on who can read Secrets and from encryption at rest on the API server. Local kind clusters do not enable the latter by default, which is fine for practice and wrong for anything real. Workloads that must hide data even from node operators need a stronger isolation layer, and [confidential containers on Kubernetes](https://shattered.io/confidential-containers-ai-kubernetes-fortanix-2026/) show where that road leads.

Set the namespace as the default for your current context to save typing in later steps. The command below edits only your local kubeconfig. Every command in the steps keeps the explicit `-n tutorial` flag so each line stands on its own, but you can drop the flag after running this.

```
kubectl config set-context --current --namespace=tutorial
```

## Step 9: Write a Production-Shaped Deployment With Probes and Limits

A Deployment declares the desired state and lets controllers chase it. You say three replicas of this image, and the ReplicaSet controller creates, replaces and removes pods until reality matches. The manifest below also encodes habits worth copying into real projects: resource requests, a memory limit, readiness and liveness probes, a read-only root filesystem, and a dropped Linux capability set. Save it as `k8s/20-deployment.yaml`.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: tutorial
  labels:
    app: web
spec:
  replicas: 3
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: web
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: web
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
        fsGroup: 10001
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: web
          image: demo-web:v1
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 8000
          envFrom:
            - configMapRef:
                name: web-config
          env:
            - name: API_TOKEN
              valueFrom:
                secretKeyRef:
                  name: web-secret
                  key: api-token
          resources:
            requests:
              cpu: 50m
              memory: 64Mi
            limits:
              memory: 128Mi
          readinessProbe:
            httpGet:
              path: /readyz
              port: http
            periodSeconds: 3
            failureThreshold: 3
          livenessProbe:
            httpGet:
              path: /healthz
              port: http
            initialDelaySeconds: 5
            periodSeconds: 10
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
          volumeMounts:
            - name: data
              mountPath: /data
      volumes:
        - name: data
          emptyDir: {}
```

Several lines carry more weight than they look. Setting `maxUnavailable: 0` with `maxSurge: 1` tells the rollout to start one new pod, wait for readiness, and only then retire an old one. The requests matter beyond scheduling, since horizontal autoscalers compute utilization against them. Without a CPU request, the setup in [Kubernetes HPA autoscaling](https://shattered.io/set-up-kubernetes-hpa-autoscaling-2026/) cannot work at all. The manifest sets a memory limit but skips a CPU limit on purpose. Memory is incompressible and a runaway process must die, whereas a CPU limit throttles a healthy pod during bursts. Plenty of teams disagree, so treat that as a default to question, not a law.

Advertisement

Apply it and watch the pods arrive. The readiness probe fails for the first five seconds because the ConfigMap sets `READY_AFTER_SECONDS` to 5, so every pod briefly shows 0/1 before flipping to 1/1.

```
kubectl apply -f k8s/20-deployment.yaml
kubectl -n tutorial get pods -o wide --watch
```
```
NAME                   READY   STATUS    RESTARTS   AGE   NODE
web-6c8f7d9b4d-7xk2p   0/1     Running   0          3s    k137-worker
web-6c8f7d9b4d-m9q4t   0/1     Running   0          3s    k137-worker2
web-6c8f7d9b4d-zr5wn   0/1     Running   0          3s    k137-worker
web-6c8f7d9b4d-7xk2p   1/1     Running   0          6s    k137-worker
web-6c8f7d9b4d-m9q4t   1/1     Running   0          6s    k137-worker2
web-6c8f7d9b4d-zr5wn   1/1     Running   0          7s    k137-worker
```

Press Ctrl+C to stop watching. Pod name suffixes are random, and the scheduler may place two pods on one worker, as shown. Control-plane nodes carry a taint that keeps ordinary workloads off them, so only the two workers host pods. If the status column shows `CreateContainerConfigError`, a referenced ConfigMap or Secret is missing. If it shows `ImagePullBackOff`, revisit Step 7.

## Step 10: Expose the App With a Service and Reach It From Your Laptop

Pods are mortal and their IP addresses change every time one is replaced. A Service gives them a stable virtual IP and a DNS name, and it routes traffic only to pods that pass their readiness probe. The Service below uses type NodePort and pins the node port to match the `containerPort` in the kind config from Step 4. Traffic to `127.0.0.1:8080` on your laptop travels into the control-plane container and on to the pods behind the Service. Save this as `k8s/30-service.yaml`.

```
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: tutorial
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - name: http
      port: 80
      targetPort: http
      nodePort: 30080
```
```
kubectl apply -f k8s/30-service.yaml
kubectl -n tutorial get service web
kubectl -n tutorial get endpointslices
curl -s http://127.0.0.1:8080/
```

The endpoint slice lists the pod addresses, and the curl call returns the JSON greeting from whichever pod answered:

```
{"message": "hello from Kubernetes 1.37", "pod": "web-6c8f7d9b4d-m9q4t", "version": "v1"}
```

Fire six requests in a row and compare the pod names. Do not expect a perfect rotation, because kube-proxy picks backends without strict round-robin. Over a few dozen requests all three pods show up.

```
for i in 1 2 3 4 5 6
do
  curl -s http://127.0.0.1:8080/
  echo
done
```

Inside the cluster, other pods reach this service at `web.tutorial.svc.cluster.local` or simply `web` from the same namespace. DNS comes from CoreDNS, which you saw running in Step 6. For a one-off peek at any Service without publishing a node port, use `kubectl -n tutorial port-forward svc/web 9000:80` and browse to localhost:9000. Port-forward ties up the terminal and works well for debugging, but it does not replace a Service.

## Step 11: Add Persistent Storage With a PersistentVolumeClaim

The web pods write their visit counter to an emptyDir volume, which lives and dies with the pod. Hit `/hit` a few times and then delete a pod, and the replacement starts again at 1. Persistent data needs a PersistentVolumeClaim. The manifest below defines a 100 MiB claim and a second Deployment named `counter`, built from the same image, that mounts it. The kind default StorageClass (named standard, backed by a local-path provisioner) creates the volume on demand. Save it as `k8s/40-counter.yaml`.

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: counter-data
  namespace: tutorial
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 100Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: counter
  namespace: tutorial
  labels:
    app: counter
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: counter
  template:
    metadata:
      labels:
        app: counter
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
        fsGroup: 10001
      containers:
        - name: counter
          image: demo-web:v1
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 8000
          envFrom:
            - configMapRef:
                name: web-config
          resources:
            requests:
              cpu: 25m
              memory: 64Mi
            limits:
              memory: 128Mi
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
          volumeMounts:
            - name: data
              mountPath: /data
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: counter-data
---
apiVersion: v1
kind: Service
metadata:
  name: counter
  namespace: tutorial
spec:
  selector:
    app: counter
  ports:
    - port: 80
      targetPort: http
```

Two choices here need explaining. The strategy is `Recreate` because a ReadWriteOnce volume attaches to one node at a time, and a rolling update could try to start the new pod before the old one releases it. And the replica count stays at 1 for the same reason. Apply the file, then prove the data survives a pod deletion.

```
kubectl apply -f k8s/40-counter.yaml
kubectl -n tutorial rollout status deployment/counter
kubectl -n tutorial get pvc
kubectl -n tutorial port-forward svc/counter 9090:80 &
curl -s http://127.0.0.1:9090/hit
curl -s http://127.0.0.1:9090/hit
curl -s http://127.0.0.1:9090/hit
```
```
NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS
counter-data   Bound    pvc-5e1d0a7c-2b3f-4c6e-9d41-7a8b2c3d4e5f   100Mi      RWO            standard

{"pod": "counter-5b7c9d8f6-k2lmn", "visits": 3}
```

The port-forward runs in the background of your shell, so the next commands can use the same terminal. Now delete the pod and watch the Deployment replace it. The port-forward dies with the old pod, so start it again before the final hit.

```
kill %1
kubectl -n tutorial delete pod -l app=counter
kubectl -n tutorial rollout status deployment/counter
kubectl -n tutorial port-forward svc/counter 9090:80 &
curl -s http://127.0.0.1:9090/hit
```

The last call returns `"visits": 4` from a brand-new pod name. The counter survived because the volume outlived the pod. Run the same experiment against the `web` pods and you see the opposite, since their emptyDir resets. A caveat for real clusters: the local-path provisioner ties each volume to one node’s disk. If that node vanishes, the data goes with it. Cloud clusters use network-attached volumes to avoid that.

## Step 12: Roll Out Version 2, Break It on Purpose, and Roll Back

Rolling updates are where Kubernetes earns its reputation. Build a second image tagged v2, load it into the nodes, annotate the Deployment so history shows why it changed, and swap the image. Open a second terminal and run `kubectl -n tutorial get pods --watch` to see pods turn over live.

```
docker build --build-arg APP_VERSION=v2 -t demo-web:v2 app/
kind load docker-image demo-web:v2 --name k137
kubectl -n tutorial annotate deployment/web kubernetes.io/change-cause="upgrade to demo-web:v2"
kubectl -n tutorial set image deployment/web web=demo-web:v2
kubectl -n tutorial rollout status deployment/web
curl -s http://127.0.0.1:8080/config
```
```
Waiting for deployment "web" rollout to finish: 1 out of 3 new replicas have been updated...
Waiting for deployment "web" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "web" rollout to finish: 1 old replicas are pending termination...
deployment "web" successfully rolled out
{"greeting": "hello from Kubernetes 1.37", "token_configured": true, "version": "v2"}
```

Requests kept succeeding the whole time, because the surge pod had to pass its readiness probe before any old pod went away. Now break it. Point the Deployment at a tag that was never loaded into the cluster. Since the pull policy is IfNotPresent and no registry holds the image, the new pod cannot start.

```
kubectl -n tutorial set image deployment/web web=demo-web:v3
kubectl -n tutorial get pods
kubectl -n tutorial rollout status deployment/web --timeout=30s
```
```
NAME                   READY   STATUS             RESTARTS   AGE
web-6c9d5b8f7d-4h2jx   1/1     Running            0          2m
web-6c9d5b8f7d-8t6vq   1/1     Running            0          2m
web-6c9d5b8f7d-p3nsz   1/1     Running            0          2m
web-7f4b6c5d8c-xw9km   0/1     ImagePullBackOff   0          25s

error: timed out waiting for the condition
```

Look at what did not happen. All three v2 pods still serve traffic. With `maxUnavailable: 0`, the broken surge pod never replaced a healthy one, so users saw no outage. That is the safety net the strategy settings buy you. Recover with one command and review the history:

```
kubectl -n tutorial rollout undo deployment/web
kubectl -n tutorial rollout status deployment/web
kubectl -n tutorial rollout history deployment/web
```

The undo returns the Deployment to its previous revision, which runs v2. History lists each revision, and the CHANGE-CAUSE column shows the annotation you set. Revisions you did not annotate show `<none>`. Add the annotation every time, or a month from now nobody will know which revision was which.

## Complete Working Project: Repo Layout and One-Command Bootstrap

Twelve manual steps teach the concepts. A script makes them repeatable, which is how you recover after breaking the cluster at 11 p.m. Arrange the files from the previous steps like this:

```
k137-tutorial/
  kind-config.yaml
  up.sh
  check.sh
  app/
    app.py
    Dockerfile
  k8s/
    00-namespace.yaml
    10-configmap.yaml
    20-deployment.yaml
    30-service.yaml
    40-counter.yaml
```

| File | Kubernetes object | What it teaches |
| --- | --- | --- |
| kind-config.yaml | kind Cluster (not a Kubernetes object) | Node count, node image, host port mapping |
| 00-namespace.yaml | Namespace | Isolation and one-command cleanup |
| 10-configmap.yaml | ConfigMap | Non-secret settings injected as environment variables |
| (created by script) | Secret | Sensitive values kept out of version control |
| 20-deployment.yaml | Deployment, ReplicaSet, Pods | Replicas, probes, limits, rolling updates |
| 30-service.yaml | Service (NodePort) | Stable address and readiness-aware routing |
| 40-counter.yaml | PVC, Deployment, Service | Persistent storage and the Recreate strategy |

The bootstrap script below creates the cluster only if it does not exist yet, builds and loads the image, generates a fresh Secret only when none exists, applies every manifest, and waits for both Deployments. Save it as `up.sh` and run `chmod +x up.sh check.sh`.

```
#!/usr/bin/env bash
set -euo pipefail

CLUSTER=k137
cd "$(dirname "$0")"

if ! kind get clusters | grep -qx "$CLUSTER"
then
  kind create cluster --config kind-config.yaml --wait 120s
fi

docker build --build-arg APP_VERSION=v1 -t demo-web:v1 app/
kind load docker-image demo-web:v1 --name "$CLUSTER"

kubectl apply -f k8s/00-namespace.yaml
if ! kubectl -n tutorial get secret web-secret > /dev/null 2>&1
then
  kubectl -n tutorial create secret generic web-secret \
    --from-literal=api-token="$(openssl rand -hex 16)"
fi

kubectl apply -f k8s/
kubectl -n tutorial rollout status deployment/web --timeout=120s
kubectl -n tutorial rollout status deployment/counter --timeout=120s
echo "Ready: http://127.0.0.1:8080/"
```

A second script checks that the cluster actually answers. It hits four endpoints through the published node port and fails loudly on any non-200 status, which makes it usable in CI later. Save it as `check.sh`.

```
#!/usr/bin/env bash
set -euo pipefail

BASE=http://127.0.0.1:8080

for path in / /healthz /readyz /config
do
  code=$(curl -s -o /dev/null -w '%{http_code}' "$BASE$path")
  echo "$path -> $code"
  [ "$code" = "200" ] || exit 1
done

echo "all checks passed"
```
```
/ -> 200
/healthz -> 200
/readyz -> 200
/config -> 200
all checks passed
```

Run `./up.sh` on a clean machine and `./check.sh` a few seconds later. The first run pulls the node image and the Python base image, so it takes several minutes. Later runs reuse both. To wipe everything, one command deletes the cluster and every container, volume and Service inside it:

```
kind delete cluster --name k137
```

Once the YAML count grows past a handful of files, raw manifests get hard to parameterize across environments. That is the moment to package them as a chart, and the [Helm 4 chart tutorial](https://shattered.io/helm-chart-tutorial-kubernetes-2026/) walks through the same kind of Deployment-plus-Service bundle. Keep the plain manifests for now. Reading them line by line is what makes a Kubernetes tutorial stick.

## Common Pitfalls That Burn Beginners

Most first-week Kubernetes pain traces back to a short list of mistakes. Each one below produced confusing symptoms for plenty of learners, and each has a one-line prevention.

- **Tagging images latest or forgetting to load them.** A kind node does not read your local Docker cache. An image tagged `latest` triggers a registry pull that fails. Use explicit tags and run `kind load docker-image` after every build.
- **Reusing a tag for changed code.** Rebuilding `demo-web:v1` and reloading it does not restart running pods, and a restarted pod may still use the cached copy. Bump the tag every time.
- **Leaving the node image unpinned.** A cluster created by a newer kind release picks that release’s default Kubernetes version. Your colleague’s cluster and yours then differ without anyone noticing. Name the image in the config, with a digest when you can.
- **Using a kubectl outside the skew window.** A 1.37 API server supports kubectl 1.36 through 1.38. Older or newer clients may behave oddly with newer API fields. The same discipline applies during cloud upgrades. Kubernetes 1.34 reached end of life on October 27, 2026, according to the project’s release schedule, and the [EKS upgrade path from 1.34 to 1.37](https://shattered.io/kubernetes-1-34-eol-eks-upgrade-1-37-extended-support-2026/) shows how fast teams have to move.
- **Expecting ConfigMap edits to reach running pods.** Environment variables injected through `envFrom` are read once at container start. After editing the ConfigMap, run `kubectl -n tutorial rollout restart deployment/web`.
- **Treating a Secret as safe because it is base64.** Anyone who can read the Secret object can decode it. Never commit Secret YAML, and limit who can read Secrets with RBAC.
- **Overlapping address ranges.** A VPN that already routes 10.244.0.0/16 or 10.96.0.0/16 breaks pod and service traffic in subtle ways. Change the ranges in the cluster config before you create the cluster, because they cannot change afterward.
- **Exposing the port to the whole network.** Leaving out `listenAddress: "127.0.0.1"` publishes your test app on every interface of your machine. On any shared network that is a real risk.

A ninth habit helps more than any single rule: read the Events section at the bottom of `kubectl describe` output before searching the web. Kubernetes usually tells you exactly what went wrong, in plain words, one screen down.

## Troubleshooting: 11 Failures and Their Fixes

Start every diagnosis with three commands: `kubectl get pods -A` for the big picture, `kubectl describe` on the failing object for events, and `kubectl logs` (add `--previous` after a crash) for the application’s own words. The table maps the symptoms you are most likely to hit to their usual causes. For problems that only appear on managed clusters, the [cloud computing archive](https://shattered.io/category/cloud-computing/) covers provider-specific setups that kind cannot reproduce.

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| kind create cluster stalls at “Starting control-plane” | Docker has too little memory or CPU, or the host uses an unsupported cgroup setup | Raise Docker’s resource limits, confirm cgroup v2, then rerun with `--retain` and collect logs with `kind export logs` |
| Error that node(s) already exist for a cluster named k137 | A previous cluster with the same name is still present | Run `kind delete cluster --name k137` and create it again |
| Cannot connect to the Docker daemon | Docker is stopped or your user lacks permission | Start Docker, add your user to the docker group, and open a new shell |
| The connection to the server localhost:8080 was refused | kubectl has no usable context in the kubeconfig | Run `kind export kubeconfig --name k137` then `kubectl config use-context kind-k137` |
| Pod shows ErrImagePull or ImagePullBackOff | The image was never loaded into the nodes, or the tag is latest | Run `kind load docker-image demo-web:v1 --name k137` and keep the pull policy at IfNotPresent |
| Pod shows CreateContainerConfigError | A referenced ConfigMap or Secret key does not exist | Create the missing object in the same namespace, then check `kubectl describe pod` |
| Pod stays at 0/1 Running | The readiness probe fails because of a wrong path, port or slow start | Call the probe path with port-forward and compare it with the manifest |
| CrashLoopBackOff or OOMKilled | The app exits on startup or exceeds the 128Mi memory limit | Read `kubectl logs --previous`, check Last State in describe, raise the limit if justified |
| curl to 127.0.0.1:8080 resets or refuses | Port mapping was missing when the cluster was created, or the Service has no ready endpoints | Check `kubectl get endpointslices` and recreate the cluster with the mapping from Step 4 |
| PersistentVolumeClaim stays Pending | The StorageClass waits for a pod to use the claim before it provisions a volume | Deploy the pod that mounts the claim, then run `kubectl describe pvc` if it persists |
| Pod stuck Pending with FailedScheduling events | Requests exceed what the kind nodes can offer under Docker’s limits | Lower requests, remove extra pods, or raise Docker’s CPU and memory |

When a cluster stays sick after two fixes, stop patching. Delete it and rerun `./up.sh`. Rebuilding takes minutes, and a clean slate beats an hour of guesswork on state you no longer understand.

## Advanced Tips: Version Matrices, Policy Gates, and the Path to a Managed Cluster

Once the base project runs, a few extensions turn this local cluster into a proper test bench. None of them need new tools beyond what you already installed.

### Run Several Kubernetes Versions Side by Side

kind supports many clusters at once, each with its own name and node image. Create a second cluster on the previous minor release to test whether your manifests survive an upgrade or a downgrade, then switch between them with `kubectl --context`. Pick the exact 1.36 image tag from the kind release notes. Your single kubectl 1.37 binary talks to both clusters, since 1.36 sits inside the supported skew window.

```
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: k136
nodes:
  - role: control-plane
    image: kindest/node:v1.36.x   # replace x with a patch tag from the kind release notes
  - role: worker
    image: kindest/node:v1.36.x
```

### Change Networks, Add Dual Stack, and Try New Feature Gates

The networking block moves pod and service ranges out of the way of a VPN. kind has supported dual-stack clusters since release 0.11 on Kubernetes 1.20 and later, and the same block switches them on. The default IPv6 ranges are fd00:10:244::/56 for pods and fd00:10:96::/112 for services.

```
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: k137-custom
networking:
  ipFamily: dual
  podSubnet: "10.200.0.0/16"
  serviceSubnet: "10.201.0.0/16"
featureGates:
  GenericWorkload: true
nodes:
  - role: control-plane
    image: kindest/node:v1.37.0
  - role: worker
    image: kindest/node:v1.37.0
```

The feature gate in that config is an experiment. Kubernetes 1.37 documentation reportedly lists scheduling groups as beta but disabled by default, behind the GenericWorkload gate. A feature in that state may also need extra API configuration, so read the 1.37 docs for it before trusting a result. Treat anything behind a gate as a lab exercise, never a base for production code.

### Harden the Namespace and Plan the Move to Managed Kubernetes

Pod Security Admission can reject pods that skip hardening. Labeling the namespace with `pod-security.kubernetes.io/enforce: restricted` makes the cluster refuse any pod that runs as root or allows privilege escalation. The web Deployment already passes. Add a `seccompProfile` of type RuntimeDefault to the counter pod first, or the restricted level will block it. Try it on a scratch namespace before you label the real one.

Advertisement

Public traffic needs an ingress controller and TLS certificates, and [cert-manager with Let’s Encrypt](https://shattered.io/cert-manager-tutorial-lets-encrypt-kubernetes-12-steps-2026/) handles the certificate half. For kind, the cloud-provider-kind project supplies LoadBalancer addresses locally. When you outgrow the laptop, the manifests from this project move almost unchanged to a managed service. Differences cluster around storage classes, load balancers and identity. The [EKS Auto Mode, GKE Autopilot and AKS Automatic comparison](https://shattered.io/eks-auto-mode-vs-gke-autopilot-vs-aks-automatic-2026/) lays out how the three big clouds handle nodes for you.

The takeaway: a three-node kind cluster pinned to the 1.37 node image gives any learner a faithful, free, disposable Kubernetes environment. Master the Deployment, Service, ConfigMap, Secret and PVC loop here, then carry the same habits to a cloud cluster.

## Frequently Asked Questions

**Which Kubernetes version does kind v0.33.0 install by default?**

It defaults to the kindest/node:v1.37.0 image, pinned by digest in its release notes. Kubernetes 1.37.1 is the newest 1.37 patch, so name the image in your config instead of relying on the default.

**What is the best Kubernetes tutorial setup for a complete beginner?**

A local multi-node kind cluster plus a matching kubectl. The Kubernetes documentation still points learners to kind for local practice, and it costs nothing. You get real scheduling across nodes without a cloud account.

Advertisement

**Which kubectl version should I install for a 1.37 cluster?**

Use kubectl 1.37.x, ideally 1.37.1. The supported skew is one minor version either way, so 1.36 and 1.38 also work. Versions outside that range are unsupported.

**Do I need Docker Desktop to run kind?**

No. Any working Docker Engine runs kind, and Linux users can install the engine alone. Docker Desktop requires a paid subscription for commercial use in organizations above 250 employees or $10 million in annual revenue, according to Docker’s release notes.

**Why does my rebuilt image not show up in the cluster?**

kind nodes keep their own image store. After each build, run `kind load docker-image` with the new tag, then point the Deployment at that tag with `kubectl set image`. Reusing an old tag leaves running pods unchanged.

**What did Kubernetes 1.37 change?**

The Garhwal release shipped on August 26, 2026 with 67 enhancements: 16 stable, 23 beta, 27 alpha and one deprecation or removal. The core objects used here, Deployments, Services, ConfigMaps, Secrets and PVCs, work as they did on earlier supported branches.

**How do I remove everything this project created?**

Run `kind delete cluster --name k137`. That removes the node containers, the volumes inside them and your kubeconfig entry. Delete the demo-web images with `docker rmi` if you also want the disk space back.

Advertisement