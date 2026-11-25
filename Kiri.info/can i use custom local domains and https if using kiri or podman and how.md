---
title: "can i use custom local domains and https if using kiri or podman and how"
source: "https://www.google.com/search?client=firefox-b-lm&q=can+i+use+custom+local+domains+and+https+if+using+kiri+or+podman+and+how"
author:
published:
created: 2026-11-24
description:
tags:
  - "clippings"
---
## Search Results

## AI Mode conversation

You said: can i use custom local domains and https if using kiri or podman and how

**AI Overview**

### AI Mode reply for can i use custom local domains and https if using kiri or podman and how

==\[Highlight start\] **Yes, you can use local domains and HTTPS with both Kiri and Podman** \[Highlight end\]== , though Kiri handles it automatically out of the box while Podman requires manual setup with a reverse proxy and local certificates.

---

1\. Using Kiri (Built-in & Automatic)

[Kiri](https://github.com/libracoder/kiri) includes a built-in local domain resolver and internal certificate authority (CA). You do not need to configure DNS or generate certificates manually.

GitHub +1

- **Automatic Naming.** Every standalone container is automatically reachable at `https://<container-name>.kiri.local`.

	GitHub

- **Docker Compose Support.** Services defined in a Compose project are automatically accessible at `https://<service>.<project>.kiri.local`.

	GitHub

- **Trusted HTTPS.** Kiri provisions and trusts its own local CA automatically so your browser connects over HTTPS without certificate warnings.

	YouTube·Alex Hitt +1

- **Customizing Ports.** By default, local domains use standard web ports (80/443). If those ports conflict with another service on your machine, you can change them using the CLI:

	GitHub

	```
	kiri domains set --http 8080 --https 8443
	```

- **Limitations on Fully Custom TLD/Domains.** Kiri restricts local automatic domains to the `*.kiri.local` namespace. If you need a completely arbitrary domain name (like `myapp.test`), you would need to fall back to the manual reverse-proxy approach described for Podman below.

	GitHub

---

2\. Using Podman (Manual Setup)

Podman does not include a built-in domain router or certificate authority for host-to-container access. To achieve custom local domains with HTTPS, combine three components:

OneUptime

Step 1: Map your custom domain to localhost

Add your custom domain to your operating system's `/etc/hosts` file (or `C:\Windows\System32\drivers\etc\hosts` on Windows). Avoid using `.local` if possible, as it can conflict with mDNS on macOS and Linux; `.test` or `.home.arpa` are safer choices.

YouTube·DB Tech

```
127.0.0.1   myapp.test api.myapp.test
```

Step 2: Generate trusted local TLS certificates

Use a tool like **mkcert** to create a local Certificate Authority, install it into your system/browser trust store, and generate certificates for your domains:

Reddit·r/selfhosted

```
mkcert -install
mkcert myapp.test "*.myapp.test"
```

This produces `myapp.test+1.pem` (certificate) and `myapp.test+1-key.pem` (private key).

Step 3: Run a reverse proxy container in Podman

Put a reverse proxy—such as **Caddy**, **Traefik**, or **Nginx**—on the same Podman network as your application containers to terminate HTTPS and route traffic by domain name.

Using **Caddy** with a `Caddyfile`:

```
myapp.test {
    tls /certs/myapp.test+1.pem /certs/myapp.test+1-key.pem
    reverse_proxy my-web-container:8080
}
```

Run Caddy in Podman attached to your container network:

```
podman network create dev-net
podman run -d --name my-web-container --network dev-net nginx
podman run -d --name caddy --network dev-net \
  -p 80:80 -p 443:443 \
  -v ./Caddyfile:/etc/caddy/Caddyfile:Z \
  -v ./certs:/certs:Z \
  caddy
```

*(Note: If you run rootless Podman on Linux, binding to ports `80` and `443` requires lowering `net.ipv4.ip_unprivileged_port_start=80` in sysctl, or mapping to high ports like `-p 8443:443`.)*

---

Summary Comparison

<table><tbody><tr><th colspan="undefined">Feature</th><th colspan="undefined">Kiri</th><th colspan="undefined">Podman</th></tr><tr><td colspan="undefined"><strong>Setup Effort</strong></td><td colspan="undefined">Zero config (automatic)</td><td colspan="undefined">Manual (<code>hosts</code> + certs + proxy)</td></tr><tr><td colspan="undefined"><strong>Domain Format</strong></td><td colspan="undefined">Fixed to <code>*.kiri.local</code></td><td colspan="undefined">Any custom domain (e.g., <code>*.test</code>)</td></tr><tr><td colspan="undefined"><strong>HTTPS / TLS</strong></td><td colspan="undefined">Built-in local CA</td><td colspan="undefined">Manual via <code>mkcert</code> + Caddy/Traefik</td></tr><tr><td colspan="undefined"><strong>Port 80/443 Handling</strong></td><td colspan="undefined">Handled natively by Kiri</td><td colspan="undefined">Requires root or <code>sysctl</code> tweak on Linux</td></tr></tbody></table>

If you let me know:

- Your **operating system** (macOS, Linux, or Windows)
- Whether you need **completely custom domain names** (like `app.test`) or if `*.kiri.local` works for your workflow

I can provide exact setup commands or a ready-to-use Compose file for your setup.

[Learn more](https://support.google.com/websearch?p=ai_overviews)

Copied to clipboardFailed to copy to clipboard. Try again later.

+2

## Shared

0 files

Transcribing…

## Web results

### [How to Create a Pod with Custom DNS in Podman](https://oneuptime.com/blog/post/2026-03-17-create-pod-custom-dns-podman/view)

OneUptime

https://oneuptime.com › Blog

OneUptime

https://oneuptime.com › Blog

Mar 17, 2026 — *Learn how to configure custom DNS servers and search domains for Podman pods*. Custom DNS settings let you control how containers in a pod...

Missing: ~~https~~ ~~kiri~~

### [libracoder/kiri: A small, fast container runtime for macOS...](https://github.com/libracoder/kiri)

GitHub

https://github.com › libracoder › kiri

GitHub

https://github.com › libracoder › kiri

16 hours ago — *Local domains*: http://\<name>.*kiri*.*local*, *with HTTPS* from *Kiri's* own certificate authority. for containers, images, volumes and networks, *HTTPS*...

### [Best Docker Desktop Alternatives 2026: OrbStack, Colima...](https://www.bitdoze.com/best-docker-desktop-alternatives/)

Bitdoze

https://www.bitdoze.com › Blog › Self-Hosting

Bitdoze

https://www.bitdoze.com › Blog › Self-Hosting

5 days ago — Comparing Docker Desktop alternatives in 2026: OrbStack, Colima, *Kiri*, *Podman* Desktop, and Rancher Desktop on pricing, RAM, macOS speed,...

### [How to Set Up a Local Podman Registry and Customize...](https://dev.to/project42/how-to-set-up-a-local-podman-registry-and-customize-podman-images-2dbc)

DEV Community

https://dev.to › project42 › how-to-set-up-a-local-podm...

DEV Community

https://dev.to › project42 › how-to-set-up-a-local-podm...

Feb 23, 2026 — By default, *Podman* expects registries to *use HTTPS*. For a *local* setup, you need to tell *Podman* it's okay to *use* HTTP for localhost.

### [How I Set Up.local Domains with Valid HTTPS in My Homelab](https://www.youtube.com/watch?v=EVnwnFY7C1w)

YouTube · DB Tech

55.1K+ views · 4 months ago

YouTube · DB Tech

55.1K+ views · 4 months ago

don't **use**.**local** don't **use**.lan either the only reserved TLD for private **use** is.internal it is reserved by ICANN and **will** never be added to...

Missing: ~~kiri~~ | Show results with: [kiri](https://www.google.com/search?num=10&newwindow=1&client=firefox-b-lm&hs=VZOW&sca_esv=06247fdd2ca646a8&sxsrf=AKL5yDhWdD6TqT7bw5lBjMbRoZOeHyYEGw:1795548982171&q=can+i+use+custom+local+domains+and+https+if+using+%22kiri%22+or+podman+and+how&sa=X&ved=2ahUKEwiF7oiaraGYAxU1OrkGHVNoGS0Q5t4CegQINhAt)

Hey there you guys! I recently found this amazing method *of* having *custom domains* on your *local* network along *with* having *HTTPS*!

[Setting up *HTTPS* for *Local* Network / Home Lab - Reddit](https://www.reddit.com/r/selfhosted/comments/1qplre0/setting_up_https_for_local_network_home_lab/)

51 posts

Jan 29, 2026

[Subdomains and *https* on a *local* network (self-signed...](https://www.reddit.com/r/selfhosted/comments/er4f7x/subdomains_and_https_on_a_local_network/)

28 posts

Jan 19, 2020

[More results from www.reddit.com](https://www.google.com/search?q=can+i+use+custom+local+domains+and+https+if+using+kiri+or+podman+and+how+site:www.reddit.com&num=10&newwindow=1&client=firefox-b-lm&hs=VZOW&sca_esv=06247fdd2ca646a8&sxsrf=AKL5yDhWdD6TqT7bw5lBjMbRoZOeHyYEGw:1795548982171&sa=X&ved=2ahUKEwiF7oiaraGYAxU1OrkGHVNoGS0QrQIoAnoECEUQAw)

Missing: ~~kiri~~ | Show results with: [kiri](https://www.google.com/search?num=10&newwindow=1&client=firefox-b-lm&hs=VZOW&sca_esv=06247fdd2ca646a8&sxsrf=AKL5yDhWdD6TqT7bw5lBjMbRoZOeHyYEGw:1795548982171&q=can+i+use+custom+local+domains+and+https+if+using+%22kiri%22+or+podman+and+how&sa=X&ved=2ahUKEwiF7oiaraGYAxU1OrkGHVNoGS0Q5t4CegQITxAB)

People also ask

## Web results

### [Make containers aware of custom local domains on the...](https://anthonysimmon.com/dotnet-aspire-containers-share-custom-hosts/)

Anthony Simmon

https://anthonysimmon.com › dotnet-aspire-containers-sh...

Anthony Simmon

https://anthonysimmon.com › dotnet-aspire-containers-sh...

Nov 4, 2024 — *Custom domains* are useful for *local* development, but containers *can*'t resolve them by default. *Using custom* hosts for *local* development is a...

Missing: ~~https~~ ~~kiri~~

### [How to implement a simple personal/private Linux...](https://www.redhat.com/en/blog/simple-container-registry)

Red Hat

https://www.redhat.com › blog › simple-container-registry

Red Hat

https://www.redhat.com › blog › simple-container-registry

Sep 8, 2020 — This article outlines the steps needed to implement a private registry as a container and store images in /opt/registry for internal *use*.

### [This Docker Alternative Starts Containers 8x Faster (Kiri)](https://skip.watch/en/qy4ajsBbOKw)

skip.watch

https://skip.watch ›...

skip.watch

https://skip.watch ›...

Nov 14, 2026 — On macOS, *HTTPS can* be enabled for such *domains*. *Kiri* also allows you to share an application running on the *local* machine: Open the application...

## Footer links

Results are personalised- [Try without personalisation](https://www.google.com/search?client=firefox-b-lm&q=can+i+use+custom+local+domains+and+https+if+using+kiri+or+podman+and+how&peek_pws=0&sxsrf=AKL5yDhWdD6TqT7bw5lBjMbRoZOeHyYEGw:1795548982171)

\-

Update location

Google apps

Google Account

Eduardo Martinez

ejmvar@gmail.com

Google membership