# Phase 2: Recognize and reach hosts by name

MagicDNS gives each Tailscale device a name based on its machine name and
tailnet DNS name. It makes a host easier to find; it does not start the
application, open a firewall, or grant access. For the actual Minihealth
workflow, use the [Phase 2 runbook](phase-2-tailscale.md).

## Establish a stable host name

1. Connect the host and client to the intended tailnet. In the Tailscale
   admin console, verify that MagicDNS is enabled and find the host on the
   Machines page.
2. Choose a descriptive machine name such as `lab-host`, and rename the
   device in the admin console if needed. Choose a name that identifies the
   host rather than one application if the host will serve several apps.
3. From an authorized client, resolve or open the host using its full
   `lab-host.<tailnet>.ts.net` name. A short machine name may work when the
   client's DNS configuration uses MagicDNS; the full name avoids relying on
   a DNS search suffix.
4. Start the Minihealth forward and Serve as described in the runbook. Open
   the exact URL Serve prints; its port is part of the address.

Renaming a Tailscale machine changes its MagicDNS name. Update bookmarks,
scripts, and any references to the old name. A machine name is not a
portable application domain: a different tailnet or a replacement machine
may need a different name. For a stable application name independent of
the host, see [the DNS options](phase-2-dns-options.md).

## Decide who can connect

Tailnet administrators manage network access in the Tailscale policy file
using grants or ACLs. Review the existing policy before changing it: access
depends on the actual rules, source identity or device, destination, and
port. Follow least privilege, and test from an authorized client **and** a
client that should be denied. Do not assume membership alone proves access
or that a hostname is an access control.

The Phase 2 workflow defaults to TCP port 8085. If a policy needs changes,
an administrator must approve and apply them; this repository does not modify
tailnet policy. Tailscale protects transport between nodes, but it does not
replace application-level authentication when that is required.

## Devices without Tailscale

| Need | Approach | Tradeoff |
| --- | --- | --- |
| Device on the same LAN | LAN DNS and a host or gateway listener reachable from that network | Requires LAN DNS, firewall and exposure controls; the current loopback-only forward is not directly reachable. |
| Private remote access | Another VPN or an approved gateway with suitable DNS | Requires its own clients or gateway, routing, authentication, and operations. |
| Public browser access | Public DNS and an intentionally public ingress or tunnel | Exposes a larger attack surface; requires TLS and appropriate authentication and protection. |
| Reach LAN resources from tailnet clients | A configured Tailscale subnet router | Lets tailnet clients reach advertised LAN resources; it does not automatically let a non-Tailscale LAN client reach this host's loopback service. |

An independent domain can remain the same across approaches, but DNS alone
cannot provide a route. Avoid `.local` as a generic private DNS suffix: it
has multicast DNS semantics and may behave differently across clients.

## When a name does not work

Check, in order: both devices are connected to the expected tailnet;
MagicDNS and client DNS are active; the machine's current name is correct;
tailnet policy allows the destination and port; and the Phase 1 forward and
Phase 2 Serve process are running. A resolvable name proves DNS only, not
that the service is reachable or healthy.

References: [MagicDNS](https://tailscale.com/docs/features/magicdns),
[machine names](https://tailscale.com/docs/concepts/machine-names),
[access controls](https://tailscale.com/docs/features/access-control),
and [subnet routers](https://tailscale.com/docs/features/subnet-routers).
