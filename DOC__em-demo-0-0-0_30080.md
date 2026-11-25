
# Docs
[Kubernetes Tutorial With kind 1.37_ 12 Steps [2026]](https://shattered.io/kubernetes-tutorial-kind-1-37-local-cluster-12-steps-2026/)

# delete kind cluster if dirty environment


# create kind cluster
```bash
kind create cluster --config kind_cluster_em-demo-0-0-0_30080.yml --wait 120s
```
```log
EM-0-0- on  main [?] 
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

EM-0-0- on  main [?] took 54s 
❯ 
```

# verify local implementation
```bash
uv run python src/backend/app.py
```
```bash
curl 127.0.0.1:8080
```
```log
What has an eye, but cannot see? A needle.
(Served by: qq-l230)
```

```bash
ssh acer  'curl qq-l230:8080'
```
```log
❯ ssh acer  'curl qq-l230:8080'
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0Why can't a bicycle stand on its own? It's two tired.
(Served by: qq-l230)
100    75  100    75    0     0    352      0 --:--:-- --:--:-- --:--:--   353
```

# create docker image and load into kubernetes registry
```bash
kind get clusters
```
```log
enabling experimental podman provider
em-demo-0-0-0
```
```bash

docker build -t joke-app:1.0 .

docker images localhost/joke-app
podman images localhost/joke-app

```
```bash
kind -n em-demo-0-0-0  load docker-image localhost/joke-app:1.0
```
```log

```

