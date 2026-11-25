default:
    @just --list

# Run the backend app and curl to test
backend-run-local:
  timeout 30 uv run backend/src/backend/app.py &
  curl localhost:8080
  tmux new -s kube-back-run

# Run the backend local-mode test three times.
backend-test-local:
    cd backend && uv run --group dev pytest tests/test_app_local.py -q --count=3

# Build the backend Docker image for local development.
backend-image-build-local:
    docker build -t joke-app:1.0 -f backend/src/backend/Dockerfile backend

# 00-00-guides:
k00-00-guides:
  echo "# https://kubezilla.io/kubernetes-learning-path-2026-first-cluster-to-production/"

# 00-00 initial cluster deletion: kind
k00-00-cluster-delete:
    echo "# Initial state: these may exist"
    kind get clusters
    kubectl cluster-info --context kind-kind

    kind delete cluster -n kind
    echo "# Final state: all must fail"
    kind get clusters
    kubectl cluster-info --context kind-kind

# 00-00 initial cluster creation: kind
k00-00-cluster-create:
    kind create cluster
    kubectl cluster-info --context kind-kind

# 01-00 deploy "Google Sample Bootcamp": Deploy the sample app and check the Deployment:
k01-00-deploy-gsb:
  kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
  kubectl get deployments

# 01-01: Expose it with a Service, then inspect the Service:
k01-01-service:
  kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080
  kubectl describe services/kubernetes-bootcamp

# Scale it out, then do a rolling update and roll it back:
k02-01-scale-out:
  kubectl scale deployments/kubernetes-bootcamp --replicas=4
# Rollout new version
k02-02-rollout-new-version:
  kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=docker.io/jocatalin/kubernetes-bootcamp:v2
  kubectl rollout status deployments/kubernetes-bootcamp
# Rollback: UNDO Rollout new version
k02-03-rollback-new-version:
  kubectl rollout undo deployments/kubernetes-bootcamp


# kubectl get pods
w-pods:
  watch -d kubectl get pods
# kubectl describe
w-describe:
  watch -d kubectl describe

# Create the em-tst-00 lab with mise.
kind-up:
    mise run kind:up

# Check the em-tst-00 lab with mise.
kind-check:
    mise run kind:check

# Delete only the em-tst-00 lab with mise.
kind-down:
    mise run kind:down

# Create or check the selected lab namespace.
kind-namespace:
    mise run kind:namespace

# Explain old-cluster removal and new-profile creation.
kind-profile-rebuild-explanation:
    @bash scripts/kind-profile-rebuild-explanation.sh

# Start the local Flask development server.
backend-local-serve:
    bash scripts/backend-local-serve.sh

# Verify the three Flask endpoints over HTTP.
backend-local-check:
    bash scripts/test-curl--local-backend.sh

# Explain local Flask verification.
backend-local-explanation:
    @bash scripts/backend-local-explanation.sh

# Build a versioned backend image.
backend-kind-build:
    bash scripts/backend-kind.sh build

# Load the image into the kind nodes.
backend-kind-load:
    mise run backend:kind:load

# Deploy the first backend version in kind.
backend-kind-deploy:
    mise run backend:kind:deploy

# Replace the running backend image in kind.
backend-kind-rollout:
    mise run backend:kind:rollout

# Forward the backend Service to port 8082.
backend-kind-forward:
    mise run backend:kind:forward

# Explain the versioned backend workflow.
backend-kind-explanation:
    @bash scripts/backend-kind-explanation.sh

# Explain the Phase 0 workflow.
kind-phase0-explanation:
    @bash scripts/kind-phase0-explanation.sh

# Copy lab files to Acer over SSH.
kind-phase0-stage-acer:
    bash scripts/kind-phase0.sh stage-acer

# Check the target host and container runtime.
kind-phase0-preflight:
    mise run kind:phase0:preflight

# Install the pinned kind and kubectl versions.
kind-phase0-install-tools:
    bash scripts/kind-phase0.sh install-tools

# Check the existing lab without changing it.
kind-phase0-check:
    mise run kind:phase0:check

# Create, check, and delete a disposable lab.
kind-phase0-smoke:
    mise run kind:phase0:smoke

# On Acer, verify backend HTTP and rollback.
backend-smoke-acer:
    mise run backend:smoke-acer

# Explain the backend smoke workflow.
backend-smoke-acer-explanation:
    @bash scripts/backend-smoke-acer-explanation.sh
