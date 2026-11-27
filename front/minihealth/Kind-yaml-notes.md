Normally Kubernetes creates a token for the pod’s service account and mounts it at /var/run/secrets/kubernetes.io/serviceaccount. The application can then use that identity to call the Kubernetes API.

Here, kind.yaml:

Applies to every container in this pod.
Prevents unnecessary Kubernetes credentials from being exposed.
Reduces the impact if the container is compromised.
Minihealth does not need Kubernetes API access, so disabling it is appropriate.
