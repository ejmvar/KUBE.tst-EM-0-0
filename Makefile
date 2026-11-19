
.PHONY: backend-test-local kind-create-cluster kind-delete-cluster kind-get-clusters help

backend-test-local: # run backend local-mode tests three times
	cd backend && uv run --group dev pytest tests/test_app_local.py -q --count=3

kind-create-cluster: # create a kind cluster using the config file
	kind create cluster --config kind_cluster_em-demo-0-0-0_30080.yml
kind-delete-cluster: # delete the kind cluster
	kind delete cluster --name em-demo-0-0-0
kind-get-clusters: # verify which clusters are available
	kind get clusters

help: # show available development and kind commands
	@grep -E '^[a-zA-Z0-9_-]+:.*#' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*# "}; {printf "%-24s %s\n", $$1, $$2}'
