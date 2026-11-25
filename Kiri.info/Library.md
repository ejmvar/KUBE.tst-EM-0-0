---
title: "Library"
source: "https://gemini.google.com/app/dd25bd5c15ac5e36"
author:
published:
created: 2026-11-24
description: "Gemini conversation with 2 messages"
tags:
  - "clippings"
---
**You**

##### You said can i use custom local domains and https if using kiri or podman and how

can i use custom local domains and https if using kiri or podman and how

---

**Gemini**

Yes, you can use custom local domains and HTTPS with both **Kiri** and **Podman**, though the setup differs significantly depending on which tool you use and whether you are on Linux or macOS.

### Option 1: Using Kiri (Built-in & Zero-Config on macOS)

If you are using **Kiri** (the lightweight container runtime):

- **macOS:** Kiri has native, automatic local domains and HTTPS termination built in. It runs its own local Certificate Authority (constrained strictly to `.kiri.local` and `.kiri.localhost`) and terminates TLS before forwarding plain HTTP to your containers.

	Kiri Docs
- **Linux & Windows:** Kiri supports plain `http://` local container names, **but built-in HTTPS termination is not supported** on Linux/Windows. You must use the Podman reverse-proxy method below instead.

	Kiri Docs

**To enable it on macOS:**

1. Open Kiri's window and go to **Settings → Domains**.

	Kiri Docs
2. Toggle **Local names** to **On** (containers will respond at `<name>.kiri.local` or `<name>.kiri.localhost`, or via the `dev.kiri.domain` label).

	Kiri Docs
3. Toggle **HTTPS** to **On** and enter your macOS password when prompted to trust Kiri's local root CA.
- *Verification:* Open `https://<container-name>.kiri.local` in your browser. It should load with a valid padlock icon and no certificate warnings.

	Kiri Docs

### Option 2: Using Podman (Reverse Proxy + mkcert on Linux/macOS)

Podman does not natively manage local DNS or TLS certificates out of the box. The standard, cleanest approach is running a reverse proxy container (like **Caddy**, **Traefik**, or **Nginx**) on a shared Podman network alongside locally trusted certificates generated via **`mkcert`**.

#### 1\. Map your custom local domain

Point your custom domain to `127.0.0.1` in `/etc/hosts` (avoid `.local` on Linux, as Avahi/mDNS intercepts it; use `.test`, `.localhost`, or `.internal`):

```
echo "127.0.0.1 myapp.test api.myapp.test" | sudo tee -a /etc/hosts
```

- *Verification:* Run `ping -c 1 myapp.test` and confirm it resolves to `127.0.0.1`.

#### 2\. Generate locally trusted certificates with mkcert

Install `mkcert` (and `libnss3-tools` on Debian/Mint/Ubuntu so Chrome/Firefox trust the local CA) and generate certificates for your domain:

```
mkdir -p ~/podman-proxy/certs
mkcert -install
mkcert -cert-file ~/podman-proxy/certs/myapp.test.pem \
       -key-file ~/podman-proxy/certs/myapp.test-key.pem \
       "myapp.test" "*.myapp.test"
```

- *Verification:* Check that both `.pem` files exist in `~/podman-proxy/certs` and that `mkcert -CAROOT` shows a valid root CA directory.

#### 3\. Configure Caddy as your TLS-terminating reverse proxy

Caddy is ideal for Podman because it requires minimal configuration and handles TLS cleanly. Create `~/podman-proxy/Caddyfile`:

```
myapp.test {
    tls /certs/myapp.test.pem /certs/myapp.test-key.pem
    reverse_proxy backend-app:8000
}
```

#### 4\. Run the network, backend, and proxy in Podman

If you are running **rootless Podman**, unprivileged users cannot bind to ports `< 1024` (`80` and `443`) by default unless you lower the unprivileged port start (`sudo sysctl net.ipv4.ip_unprivileged_port_start=80`) or map high ports (e.g., `-p 8443:443`).

```
# 1. Create a shared Podman network for DNS resolution between containers
podman network create local-dev

# 2. Start your application container on that network (no host ports needed)
podman run -d --name backend-app --network local-dev your-app-image

# 3. Start Caddy with your Caddyfile and certs mounted (:Z for SELinux compatibility if applicable)
podman run -d --name reverse-proxy \
  --network local-dev \
  -p 80:80 -p 443:443 \
  -v ~/podman-proxy/Caddyfile:/etc/caddy/Caddyfile:ro,Z \
  -v ~/podman-proxy/certs:/certs:ro,Z \
  docker.io/library/caddy:alpine
```

- *Verification:* Run `curl -I [https://myapp.test](https://myapp.test)`. You should receive an `HTTP/2 200` (or your app's status code) with zero SSL certificate errors.

Want a Quadlet or Compose template so this starts automatically?