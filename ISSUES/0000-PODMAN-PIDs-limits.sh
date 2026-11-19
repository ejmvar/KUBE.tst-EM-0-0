#!/bin/bash

2. 
Raise the Podman PIDs limit.
This fixes the cause for the whole cluster.
Edit ~/.config/containers/containers.conf (rootless) or /etc/containers/containers.conf:
```bash
#If you're not sure which mode you use, run podman info --format '{{.Host.Security.Rootless}}'. true means rootless.
#If you're not sure which mode you use, run 
podman info --format '{{.Host.Security.Rootless}}'
#. true means rootless.

# ❯ podman info --format '{{.Host.Security.Rootless}}'
# true

mkdir -p  ~/.config/containers/
nvim ~/.config/containers/containers.conf

```
```toml
[containers]
pids_limit = 0   # 0 = unlimited, or set e.g. 16384
```
Then recreate the cluster, because the limit is only applied when the node container is created:
```bash
kind delete cluster
KIND_EXPERIMENTAL_PROVIDER=podman kind create cluster --config <your-config>.yaml
```

If you use rootless Podman, also check that your systemd user slice isn't limiting tasks (systemctl --user show user.slice | grep TasksMax).

After either fix, the fatal worker errors should go away. Other workloads you add to the kind cluster are less likely to hit the same limit too.




