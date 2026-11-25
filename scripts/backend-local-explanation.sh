#!/usr/bin/env bash
cat <<'TEXT'
Objective: verify the minimal Flask app over HTTP on the local machine.

1. Start: mise run backend:local:serve
   Success: Flask listens on 127.0.0.1:8080 in the foreground.
   Failure: install uv if missing; if the port is occupied, identify the
   listener or set BACKEND_PORT in both terminals. Do not stop an unknown process.
2. In another terminal, run mise run backend:local:check.
   Success: GET / returns a joke and hostname, GET /health returns Ok, and
   GET /health/hostname returns the hostname marker. All return HTTP 200.
   Failure: the checker reports the affected route and exits nonzero for a
   connection error, unexpected status, or unexpected response body.
3. Stop the foreground server with Ctrl-C.
   Success: the shell prompt returns; the task leaves no server running.

Make and Just equivalents: backend-local-serve and backend-local-check.
No SSH or Kubernetes is involved.
TEXT
