.DEFAULT_GOAL := help

.PHONY: backend-test-local backend-image-build-local kind-create-cluster kind-delete-cluster kind-get-clusters help
.PHONY: kind-up kind-check kind-down
.PHONY: kind-phase0-explanation kind-phase0-stage-acer kind-phase0-preflight kind-phase0-install-tools kind-phase0-check kind-phase0-smoke
.PHONY: backend-smoke-acer backend-smoke-acer-explanation

backend-test-local: # run backend local-mode tests once
	cd backend && uv run --group dev pytest tests/test_app_local.py -q

backend-image-build-local: # build the backend Docker image for local development
	docker build -t joke-app:1.0 -f backend/src/backend/Dockerfile backend

kind-create-cluster: # create a kind cluster using the config file
	kind create cluster --config kind_cluster_em-demo-0-0-0_30080.yml
kind-delete-cluster: # delete the kind cluster
	kind delete cluster --name em-demo-0-0-0
kind-get-clusters: # verify which clusters are available
	kind get clusters

kind-up: # create the em-tst-00 lab with mise
	mise run kind:up
kind-check: # check the em-tst-00 lab with mise
	mise run kind:check
kind-down: # delete only the em-tst-00 lab with mise
	mise run kind:down

kind-phase0-explanation: # explain the Phase 0 workflow
	bash scripts/kind-phase0-explanation.sh
kind-phase0-stage-acer: # copy lab files to Acer over SSH
	bash scripts/kind-phase0.sh stage-acer
kind-phase0-preflight: # check the target host and container runtime
	mise run kind:phase0:preflight
kind-phase0-install-tools: # install the pinned kind and kubectl versions
	bash scripts/kind-phase0.sh install-tools
kind-phase0-check: # check the existing lab without changing it
	mise run kind:phase0:check
kind-phase0-smoke: # create, check, and delete a disposable lab
	mise run kind:phase0:smoke
backend-smoke-acer: # on Acer, verify backend HTTP and rollback
	mise run backend:smoke-acer
backend-smoke-acer-explanation: # explain the backend smoke workflow
	bash scripts/backend-smoke-acer-explanation.sh


.PHONY: backend-local-serve backend-local-check backend-local-explanation
backend-local-serve: # start the local Flask development server
	bash scripts/backend-local-serve.sh
backend-local-check: # verify the three Flask endpoints over HTTP
	bash scripts/test-curl--local-backend.sh
backend-local-explanation: # explain local Flask verification
	bash scripts/backend-local-explanation.sh

.PHONY: backend-kind-build backend-kind-load backend-kind-deploy backend-kind-rollout backend-kind-forward backend-kind-explanation
backend-kind-build: # build a versioned backend image
	bash scripts/backend-kind.sh build
backend-kind-load: # load the image into the kind nodes
	mise run backend:kind:load
backend-kind-deploy: # deploy the first backend version in kind
	mise run backend:kind:deploy
backend-kind-rollout: # replace the running backend image in kind
	mise run backend:kind:rollout
backend-kind-forward: # forward the backend Service to port 8082
	mise run backend:kind:forward
backend-kind-explanation: # explain the versioned backend workflow
	bash scripts/backend-kind-explanation.sh

.PHONY: kind-namespace kind-profile-rebuild-explanation
kind-namespace: # create or check the selected lab namespace
	mise run kind:namespace
kind-profile-rebuild-explanation: # explain old-cluster removal and new-profile creation
	@bash scripts/kind-profile-rebuild-explanation.sh

.PHONY: minihealth-kind-deploy minihealth-kind-forward minihealth-kind-check minihealth-kind-explanation
minihealth-kind-deploy: # build, load, and deploy Minihealth to kind
	bash scripts/minihealth-kind.sh deploy
minihealth-kind-forward: # forward Minihealth to localhost:8083
	bash scripts/minihealth-kind.sh forward
minihealth-kind-check: # verify the frontend and its three API routes
	bash scripts/test-minihealth-kind.sh
minihealth-kind-explanation: # explain the Minihealth kind workflow
	bash scripts/minihealth-kind-explanation.sh


# ==============================
# kind-phase1
# ------------------------------
.PHONY: kind-phase1-deploy kind-phase1-check kind-phase1-forward kind-phase1-explanation
kind-phase1-deploy: # deploy Flask and Minihealth in separate kind namespaces
	mise run kind:phase1:deploy
kind-phase1-check: # verify Minihealth and its proxied Flask routes
	mise run kind:phase1:check
kind-phase1-forward: # forward Minihealth to the local browser
	mise run kind:phase1:forward
kind-phase1-explanation: # explain Phase 1 without running it
	bash scripts/kind-phase1-explanation.sh

.PHONY: kind-phase2-serve kind-phase2-check kind-phase2-explanation
kind-phase2-serve: # share the local frontend privately with Tailscale
	mise run kind:phase2:serve
kind-phase2-check: # check the frontend through its Tailscale name
	mise run kind:phase2:check
kind-phase2-explanation: # explain Phase 2 without running it
	bash scripts/kind-phase2-explanation.sh


help: # show available development and kind commands
	@grep -E '^[a-zA-Z0-9_-]+:.*#' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*# "}; {printf "%-24s %s\n", $$1, $$2}'
