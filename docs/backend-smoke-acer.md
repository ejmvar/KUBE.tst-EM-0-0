# Backend smoke test on bare-metal Acer

On 2026-11-25, the existing Podman-backed kind cluster on `acer` passed an
in-cluster HTTP and rollback check. The smoke test used a temporary namespace.
It did not test LAN access, a fresh cluster install, or production serving.

## Run it

Print the steps and their expected outcomes with
`make backend-smoke-acer-explanation`, `just backend-smoke-acer-explanation`,
or `mise run backend:smoke-acer:explanation`.

On Acer, in a checkout or a [staged lab directory](phase-0-kind-lab.md#1-get-the-files-onto-acer):

```bash
mise run kind:phase0:check
mise run backend:smoke-acer
```

`make backend-smoke-acer` and `just backend-smoke-acer` run the same
`scripts/backend-smoke-acer.sh` workflow. It only targets `kind-em-tst-00`.

## What the script does
1. Over SSH, use `kubectl --context kind-em-tst-00` explicitly. Build an
   image with Podman from `backend/src/backend/Dockerfile` and `app.py` in
   a temporary directory. Use a unique tag such as
   `localhost/joke-app:smoke-<run-id>`.
2. Save the image with `podman save --format docker-archive -o node-image.tar
   "$image"` and import it with `KIND_EXPERIMENTAL_PROVIDER=podman kind load
   image-archive --name em-tst-00 node-image.tar`.
3. Create a new test namespace and run a single-replica `joke-app`
   Deployment in it with `imagePullPolicy: Never` and HTTP readiness on
   `/` at port 8080. Expose a ClusterIP Service named `joke-app` on port 80
   targeting 8080. Use a separate client pod in the same namespace.
4. Wait for `kubectl rollout status deployment/joke-app --timeout=60s`,
   then request `http://joke-app/` from the client with a bounded retry.
   Require HTTP 200 and the `(Served by:` marker in the response.
5. Patch only the test Deployment to run `python -c 'raise SystemExit(1)'`.
   Require `kubectl rollout status deployment/joke-app --timeout=15s` to
   time out, then run `kubectl rollout undo deployment/joke-app`. Wait for
   rollout success and repeat the HTTP assertion.
6. Delete only the test namespace and remove the temporary build directory.
   The test image may remain cached in Podman and kind.

All namespaced `kubectl` commands must include `-n <test-namespace>`.
The existing cluster should stay running.

## Observed results

- The first request immediately after rollout was refused despite the pod
  being Ready. A separate client also saw one refused request on the
  follow-up run, then got HTTP 200 about one second later. Pod readiness is
  not sufficient proof that the Service can already route traffic.
- The bad revision timed out after 15 seconds, rollback succeeded, and the
  Service returned HTTP 200 again. Both test namespaces were deleted.
