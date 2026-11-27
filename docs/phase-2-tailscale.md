# Phase 2: Reach Minihealth by Tailscale machine name

This workflow shares the Phase 1 frontend and its `/api/` routes with
authorized tailnet devices. It uses HTTP on port 8085 within Tailscale, not
public internet access. Tailscale encrypts traffic between tailnet nodes;
HTTP itself is not end-to-end TLS. See [DNS and access options](phase-2-dns-options.md)
for the tradeoffs and future HTTPS or non-Tailscale choices.
For MagicDNS, machine naming, policy, and alternatives, see
[host names and access](phase-2-host-names.md).

Run `make kind-phase2-explanation`, `just kind-phase2-explanation`, or
`mise run kind:phase2:explanation` for the [ordered steps and signals](../scripts/kind-phase2-explanation.sh).
Both host and client must be connected to the same tailnet, MagicDNS must
resolve the host name, and tailnet policy must allow the client to reach
the host. Inspect existing Serve routes with `tailscale serve status` before
starting: the task configures an HTTP route on the chosen port.

1. In a terminal on the cluster host, start the Phase 1 forward:

   ```sh
   CLUSTER_NAME=test-0 make kind-phase1-forward
   ```

   Use the correct cluster name for your host. Leave the terminal open.
2. In another host terminal, start the foreground Serve proxy:

   ```sh
   make kind-phase2-serve
   ```

   Leave it open and use the URL printed by Tailscale. Stop it with Ctrl-C;
   do not use `tailscale serve reset`, which removes unrelated Serve routes.
3. On an authorized tailnet client, open the printed URL. Expect three
   HTTP 200 results. To check from a device with this repository and tools:

   ```sh
   PHASE2_HOST=<machine-name.tailnet-name.ts.net> make kind-phase2-check
   ```

   Replace the placeholder with the machine name; `tailscale status` on the
   host displays it. The check requests the UI and all three API routes.

All three Phase 2 actions are also available through Just (same hyphenated
names) and mise (`kind:phase2:serve`, `kind:phase2:check`,
`kind:phase2:explanation`). Set `PHASE2_PORT` consistently on host and client
if 8085 is in use; if the local forward uses another port, set `PHASE1_PORT`
to the same value when starting the forward and Serve. A changed port is
part of the URL. If the proxy fails, inspect Serve output and tailnet policy;
if the UI fails, confirm the Phase 1 check and both foreground processes.

## Test the workflow without a cluster

Run `make kind-phase2-test`, `just kind-phase2-test`, or
`mise run kind:phase2:test`. Each runs
[`scripts/test-kind-phase2.sh`](../scripts/test-kind-phase2.sh), which uses
stubbed Tailscale and HTTP commands to check routing, port overrides, and
invalid inputs. Success prints `Phase 2 routing tests passed.` A failure
exits nonzero. This is not a substitute for the live tailnet check above.
