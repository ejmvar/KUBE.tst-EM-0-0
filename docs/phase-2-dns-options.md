# Phase 2: Choose a name and access boundary

**Status: private Tailscale machine-name workflow; public access is not configured.** Phase 1 serves Minihealth
and proxies its `/api/` routes within Kubernetes. Its port-forward binds to
`127.0.0.1`, so other devices cannot use it directly. Phase 2 must choose
both a name and a way to reach the service; DNS alone does not expose a port.

## Access from this computer, the LAN, and elsewhere

| Scope | Example URL | What is needed |
| --- | --- | --- |
| This computer | `http://localhost:8083/` | Phase 1 loopback port-forward. No custom DNS or Tailscale required. |
| Local network | `http://minihealth.example.com/` | A DNS record visible to LAN clients, a reachable listener on the host, and appropriate firewall rules. The record must point to that host or a suitable gateway. |
| Remote, private | `https://lab.tail1234.ts.net/` | Tailscale on the host and authorized client devices, MagicDNS, and Tailscale Serve or another reachable listener. Tailnet access policies still apply. |
| Remote, public | `https://minihealth.example.com/` | Public DNS and a deliberately public ingress or tunnel, plus TLS and access controls. This is a different security decision from private tailnet access. |

Names, ports, and domains above are examples. Do not use `example.com` as if
it were a domain we own. `/api/`, `/api/health`, and `/api/health/hostname`
can use the same host as the UI, so browsers need only one origin.

## Tailscale machine name or an independent application name?

| Choice | Benefits | Costs and limitations |
| --- | --- | --- |
| MagicDNS machine name, e.g. `lab.tail1234.ts.net` | Simple private remote access; identifies the host without maintaining our own DNS. Serve can add HTTPS for the tailnet. | The name is tied to the Tailscale machine and tailnet; renaming the machine changes its DNS name. Devices without tailnet access cannot use it as a general LAN or internet name. |
| Own domain, e.g. `minihealth.example.com` | Application identity can stay the same when the host or network provider changes. Different DNS answers can direct LAN and remote clients to suitable gateways. | Requires a domain and DNS management, reachable endpoints, certificates for HTTPS, and potentially split DNS. An independent name does **not** by itself provide a secure network path. |

An own domain can be used with Tailscale if clients can resolve it to a
reachable private endpoint and the host serves the requested name. Tailscale
[split DNS](https://tailscale.com/docs/features/split-dns-policies) can
direct a domain to a DNS server; it does not create the DNS record or the
server. Verify certificate and proxy requirements for the chosen endpoint.

## Without Tailscale later

Keep the application name independent of the access provider if portability
is the priority. A LAN DNS server can resolve it to a LAN gateway; a different
VPN can provide remote private routing and DNS; a public reverse proxy can
serve internet users if public access is explicitly intended. Each alternative
still needs firewall, authentication, TLS, and operational decisions. A
`*.ts.net` name alone is not portable to those environments.

## Security and operational boundaries

- Tailscale Serve is intended for private tailnet sharing; Tailscale Funnel
  exposes a service to the public internet. Do not enable Funnel merely to
  reach authorized tailnet devices.
- Use HTTPS for remote use. MagicDNS short names can work over HTTP, but
  Tailscale's documented HTTPS certificate name is the fully qualified
  `*.ts.net` name. Certificate Transparency publishes certificate names.
- Tailscale network access policies limit which tailnet devices can connect;
  they do not replace application authentication where that is needed.
- HTTP on a LAN is unencrypted. DNS records and hostnames are not access
  controls; avoid exposing the Flask development server directly.
- A service bound only to loopback needs a local proxy such as Serve for
  remote access; LAN clients need a separate reachable listener or gateway.

Sources: [MagicDNS](https://tailscale.com/docs/features/magicdns),
[Serve](https://tailscale.com/docs/use-cases/application-testing/share-local-dev-server-with-team),
[Funnel](https://tailscale.com/docs/use-cases/application-testing/share-local-dev-server-with-internet),
and [Tailscale HTTPS certificates](https://tailscale.com/docs/how-to/set-up-https-certificates).

## Decision before implementation

Choose whether Phase 2 should start with the Tailscale machine name or an
owned application domain, and whether public internet access is actually
required. Then select the gateway, DNS records, TLS, and tests for that
boundary. No public exposure or DNS changes are performed by this document.
