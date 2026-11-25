
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

help: # show available development and kind commands
	@grep -E '^[a-zA-Z0-9_-]+:.*#' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*# "}; {printf "%-24s %s\n", $$1, $$2}'
