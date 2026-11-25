---
title: "Chatbot App - AI Chatbot"
source: "https://chatbot.app/chats/OyldjYrYWftjpcJGtw8m?model=claude-4.8-opus"
author:
published: 2026-11-24
created: 2026-11-24
description: "Chatbot App - AI Chatbot"
tags:
  - "clippings"
---
Your Chats

can i use custom local domains and https if using kiri or podman and how

I'm looking at a technical question about local development with Podman, custom domains, and HTTPS. The "Kiri" name might be a typo or a specific tool I'm not sure of, and since this is fairly general knowledge, I think I can answer from what I know without searching.

Going with my knowledge here, since this is general Podman and local HTTPS territory. I'm not certain what "kiri" refers to, so I'll stick to Podman and the common approaches to custom local domains.

Yes — you can absolutely use custom local domains (like `myapp.local` or `app.test`) **and** HTTPS with Podman (and with Kind, if that's what "kiri" refers to). The container engine itself doesn't provide this; you set it up with a few standard pieces. Here's how it works.

## The building blocks

You need three things:

1. **A hostname that resolves to your machine** (the custom domain)
2. **A TLS certificate** that your browser/system trusts for that domain
3. **A reverse proxy** in front of your containers to terminate HTTPS and route by hostname

## 1\. Custom local domain

**Option A — `/etc/hosts` (simplest):**

```
127.0.0.1   myapp.local api.myapp.local
```

On Windows: `C:\Windows\System32\drivers\etc\hosts`.

**Option B — wildcard DNS (better for many subdomains):** Use `dnsmasq` to route an entire TLD to localhost:

```
# /usr/local/etc/dnsmasq.conf  (or /etc/dnsmasq.conf)
address=/.test/127.0.0.1
```

Then anything `*.test` resolves locally. Use `.test` or `.localhost`, **not** `.local` (reserved for mDNS/Bonjour) and **not** `.dev` (forced-HTTPS by browsers via HSTS, which can fight you).

## 2\. Trusted HTTPS certificate

The easiest reliable tool is **mkcert**, which creates a local CA and installs it into your system/browser trust store:

```bash
mkcert -install
mkcert myapp.test "*.myapp.test"
```

This produces a cert + key file you then hand to your proxy. Browsers will show a valid padlock with no warnings.

## 3\. Reverse proxy in a container

Run the proxy in Podman and route to your app containers by hostname.

**Caddy** (auto-handles TLS, very concise):

```
# Caddyfile
myapp.test {
    tls /certs/myapp.test.pem /certs/myapp.test-key.pem
    reverse_proxy app:8080
}
```

```bash
podman run -d --name proxy \
  -p 443:443 -p 80:80 \
  -v ./Caddyfile:/etc/caddy/Caddyfile:Z \
  -v ./certs:/certs:Z \
  docker.io/library/caddy
```

**Traefik** and **nginx** work equally well; with Traefik you can auto-discover containers via labels.

## Tips specific to Podman

- Put the proxy and your apps on the **same Podman network** so the proxy can reach them by container name:bash

	Collapse

	Copy

	```bash
	podman network create devnet
	podman run --network devnet --name app ...
	```
- On SELinux systems (Fedora/RHEL), add `:Z` to volume mounts (shown above) so the container can read your cert files.
- Rootless Podman can't bind ports below 1024 by default. Either run the proxy on `8443`, or lower the threshold:bash

	Collapse

	Copy

	```bash
	sudo sysctl net.ipv4.ip_unprivileged_port_start=443
	```
- A **Podman Compose / `podman play kube`** file is the cleanest way to declare the proxy + apps + network together.

### If you meant Kind (Kubernetes in Docker/Podman)

The same concepts apply, but you'd use an **Ingress controller** (nginx-ingress or Traefik) instead of a standalone proxy, create a Kubernetes TLS secret from your mkcert cert, and reference it in an Ingress resource with your custom host.

If you let me know which tool "kiri" specifically is and your OS, I can give you exact copy-paste commands for your setup.

Chatbot App is AI and can make mistakes. Check important information.

Add Anything

Drop your files here