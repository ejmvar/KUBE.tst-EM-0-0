# Verify the minimal backend locally

Start with `make backend-local-explanation`, `just backend-local-explanation`,
or `mise run backend:local:explanation`. You need `uv`, Python 3.14 or
later, and `curl`.

1. In one terminal, run `mise run backend:local:serve`.
2. In another, run `mise run backend:local:check`.
3. Stop the foreground server with Ctrl-C when finished.

Make and Just expose the same scripts as `backend-local-serve` and
`backend-local-check`. The server binds to loopback only.

| Request | Expected result |
| --- | --- |
| `curl -i localhost:8080/` | HTTP 200, a joke, and `(Served by: <hostname>)` |
| `curl -i localhost:8080/health` | HTTP 200 and `Ok` |
| `curl -i localhost:8080/health/hostname` | HTTP 200 and `(Served by: <hostname>)` |

If another process owns port 8080, leave it alone unless you know you can
restart it. To verify the current source separately, prefix both the serve
and check commands with `BACKEND_PORT=8081` (or another free port).

This check is local HTTP only. Repeat it on Acer and in a fresh VM later.
