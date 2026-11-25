
.PHONY: backend-test-local kind-create-cluster kind-delete-cluster kind-get-clusters help

backend-test-local: # run backend local-mode tests three times
	cd backend && uv run --group dev pytest tests/test_app_local.py -q --count=3

kind-create-cluster: # create a kind cluster using the config file
	kind create cluster --config kind_cluster_em-demo-0-0-0_30080.yml
kind-delete-cluster: # delete the kind cluster
	kind delete cluster --name em-demo-0-0-0
kind-get-clusters: # verify which clusters are available
	kind get clusters

.PHONY: kind-up kind-check kind-down
kind-up: # create the em-tst-00 lab with mise
	mise run kind:up
kind-check: # check the em-tst-00 lab with mise
	mise run kind:check
kind-down: # delete only the em-tst-00 lab with mise
	mise run kind:down

.PHONY: kind-namespace kind-profile-rebuild-explanation
kind-namespace: # create or check the selected lab namespace
	mise run kind:namespace
kind-profile-rebuild-explanation: # explain old-cluster removal and new-profile creation
	@bash scripts/kind-profile-rebuild-explanation.sh

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


help: # show available development and kind commands
	@grep -E '^[a-zA-Z0-9_-]+:.*#' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*# "}; {printf "%-24s %s\n", $$1, $$2}'
