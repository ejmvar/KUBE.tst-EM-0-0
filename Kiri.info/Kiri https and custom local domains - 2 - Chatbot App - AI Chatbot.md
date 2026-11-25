---
title: "Chatbot App - AI Chatbot"
source: "https://chatbot.app/chats/OyldjYrYWftjpcJGtw8m?model=claude-5.2-fable"
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

i am asking about podman and kiri from github/libracoder/kiri

Nov 24, 4:38 PM

I'm not sure I know the "kiri" project from github/libracoder/kiri well enough to answer from memory, and I don't want to invent details about an unfamiliar repo. Handing this to the Research Assistant makes sense, since it can search the web for what the project actually is.

Investigating Custom Domains

I'm currently exploring how to integrate custom local domains and HTTPS with Podman and the kiri tool. My focus is on understanding the configuration requirements and potential challenges involved in achieving this setup.

Exploring Local Domains

I'm currently investigating how to implement custom local domains and HTTPS specifically for Podman and Kiri, understanding Kiri's role as a lightweight container runtime is a starting point.

Synthesizing Kiri Solutions

I've confirmed Kiri's Docker API compatibility means standard reverse proxy solutions for local domains and HTTPS will apply. My focus is now on detailing how this works in practice for Kiri, leveraging existing Docker/Podman networking principles and local DNS configurations.

Yes, you can absolutely use custom local domains and HTTPS with **Kiri**, just as you would with Docker or Podman.

Because Kiri is designed to be compatible with the Docker Engine API and works with the standard Docker CLI and Compose tools, the entire ecosystem of containerized reverse proxies, local certificate management, and DNS tricks applies to it exactly the same way.

Here is how to approach this for Kiri:

### The Workflow

To achieve custom local domains and HTTPS, you need the same three components regardless of the runtime:

1. **DNS/Hostname Resolution:** You must map your custom domain (e.g., `myapp.test`) to your local machine (`127.0.0.1`).
2. **Local Certificate Authority (CA):** You need to generate valid, trusted certificates for your local machine.
3. **Reverse Proxy:** You need a containerized proxy running in Kiri to terminate HTTPS traffic and route it to your application containers.

---

### Step-by-Step Implementation

#### 1\. Custom Local Domain

You need your machine to resolve your domain to `localhost`.

- **Simple:** Edit your `/etc/hosts` file (on Windows: `C:\Windows\System32\drivers\etc\hosts`).text

	Collapse

	Copy

	```
	127.0.0.1  myapp.test
	```
- **Advanced:** Use a tool like `dnsmasq` if you need a wildcard domain (e.g., `*.test`) so you don't have to edit `hosts` every time you add a new project.

#### 2\. Trusted HTTPS Certificates

Use **github.com**. It is the industry standard for local development because it creates a local CA and installs it into your system’s trust store automatically.

```bash
# Install the local CA
mkcert -install

# Create a cert for your domain
mkcert myapp.test "*.myapp.test"
```

This generates two files (`myapp.test.pem` and `myapp.test-key.pem`) that you will mount into your proxy container.

#### 3\. Reverse Proxy (The Kiri Setup)

Since Kiri speaks the Docker API, you can use any containerized reverse proxy. **Caddy** is highly recommended for local setups because it handles HTTPS certificate automation automatically if configured to do so, or it can easily load the `mkcert` files you created.

**Example Caddyfile:**

```
myapp.test {
    # If using your own mkcert files:
    tls /certs/myapp.test.pem /certs/myapp.test-key.pem
    
    # Or, if you let Caddy handle it (may require extra config):
    reverse_proxy app_container:8080
}
```

**Running it in Kiri:**

```bash
# Create a shared network so the proxy can talk to your app
docker network create devnet

# Run your app
docker run -d --name app_container --network devnet my-app:latest

# Run the proxy
docker run -d --name proxy \
  -p 443:443 -p 80:80 \
  -v ./Caddyfile:/etc/caddy/Caddyfile:ro \
  -v ./certs:/certs:ro \
  --network devnet \
  caddy:latest
```

### Summary of Differences

- **Compatibility:** Kiri's primary advantage here is that it replaces the heavyweight Docker Desktop daemon with a lighter alternative while *keeping* the Docker API compatibility.
- **Infrastructure:** Kiri does not manage the proxy or the DNS itself; these remain external responsibilities managed by standard container practices.
- **Tooling:** Any `docker-compose.yml` or `docker` CLI command you use to set up proxies with Docker or Podman will work exactly the same way when directed at the Kiri socket.

remember i work under linux (linuxmint, ubuntu, debian, aws amis)

Nov 24, 5:29 PM

The user is on Linux (Mint, Ubuntu, Debian, AWS AMIs), so I need to tailor the answer to Linux for both Podman and Kiri. Kiri is a tool I don't know well, but the research says it runs containers in a small Linux VM or directly on the kernel on Linux, and it speaks the Docker Engine API. I'm weighing whether to hand this off to the research assistant.

I'm weighing whether to hand this to the research assistant, since I can't verify Kiri's built-in domain and HTTPS features without search. The user is asking specifically about Kiri, and its "free Ngrok alternative" angle suggests public tunnel URLs matter here, so checking the docs seems worthwhile.

Investigating Podman and Kiri

I'm currently exploring how to best configure local domains and HTTPS with Podman and Kiri on Linux distributions like Mint, Ubuntu, and Debian, as well as AWS AMIs. My focus is on practical application for your specific environment.

Exploring Podman Networking

I'm currently digging into how Podman's networking, particularly with Netavark and Aardvark-dns, differs from Kiri's Docker API compatibility, focusing on Linux-specific configurations like `systemd-resolved` and `/etc/hosts` for local domain resolution.

Validating Linux Network Configurations

I've confirmed Caddy and Nginx function perfectly within standard Linux environments. My current efforts are focused on detailing how Podman's native DNS and networking tools, unlike Kiri's Docker API emulation, integrate seamlessly with Linux-specific configurations like `systemd-resolved` and `/etc/hosts`.

Working on Linux (whether local distributions like Linux Mint, Ubuntu, Debian, or cloud instances like AWS AMIs) gives you significantly more control over networking, making local domain and HTTPS management straightforward and powerful.

Because Podman and Kiri operate differently, your networking strategy should adapt to the strengths of each.

### 1\. Podman on Linux

Podman is daemonless and designed to be rootless, which changes how it handles networking compared to the Docker API model.

- **Native DNS (Aardvark-dns):** Podman uses `aardvark-dns` to automatically provide DNS resolution for containers within a pod or network. You don't need complex workarounds to make containers talk to each other; they are resolvable by their container name by default.
- **Networking Strategy:**
	- **External/Host Access:** Podman bridges containers to the host network via CNI/Netavark. To expose a service to your machine for HTTPS, you bind ports to the host (`-p 443:443`).
	- **Rootless/Rootful:** If you run rootless, you must ensure your user has permission to bind to privileged ports (like 443). You can use a `sysctl` adjustment to allow binding to low ports:bash

		Collapse

		Copy

		```bash
		sudo sysctl -w net.ipv4.ip_unprivileged_port_start=80
		```
- **Recommendation:** Use `podman-compose` for your setup. It bridges the gap between Compose and Podman's native networking.

### 2\. Kiri on Linux

Kiri speaks the Docker API. On Linux, it is typically more efficient than on macOS/Windows because it doesn't require a virtual machine (VM) layer.

- **Docker API Compatibility:** Kiri mimics the Docker networking model. This means it relies on bridge networks and external DNS/Proxy management.
- **Networking Strategy:**
	- **Bridge Networks:** You will need to create user-defined bridge networks (`docker network create devnet`) for your containers to resolve each other by name.
	- **External Proxy:** As with the previous advice, you will run a containerized proxy (like Caddy or Nginx) as a container on that network, mapping ports to the host.

### 3\. The Linux-Native Workflow for HTTPS/Domains

On Linux, you have superior tools to integrate your container networking with the OS.

#### A. Hostname Resolution

Instead of manually editing `/etc/hosts` for every project, use the native Linux resolver.

- **systemd-resolved:** Most modern Linux distros use `systemd-resolved`. You can configure local DNS resolution for specific domains.
- **Simple approach:** Add your domains to `/etc/hosts` for simplicity.
- **Advanced approach (Recommended for development):** Install `dnsmasq` to act as a local DNS server that resolves `*.test` to `127.0.0.1` automatically, saving you from constant `/etc/hosts` updates.

#### B. Certificate Management (mkcert)

`mkcert` is highly reliable on Linux. The benefit here is that you can easily install the CA into your system trust store once:

```bash
# Install dependencies (varies by distro)
sudo apt install libnss3-tools 

# Generate CA
mkcert -install
```

Your containers can then mount the generated certificates, and they will be "trusted" by browsers running on that same Linux machine (including headless browsers or CLI tools using `curl` or `wget`).

#### C. Reverse Proxy (The "Linux Way")

While you *can* use a containerized Caddy instance, on Linux, you also have the option of running the proxy directly on the host (e.g., installing Caddy via `apt` or binary).

- **Host Proxy Benefit:** Running the proxy on the host makes it easier to manage certificates across all containers and services without managing internal Docker/Kiri bridge networks.
- **Container Proxy Benefit:** Keeping the proxy in a container (Kiri/Podman) keeps your host environment clean and makes your development environment portable across different Linux machines/AMIs.

### Summary Comparison for your Linux Workflow

| Feature | Podman | Kiri |
| --- | --- | --- |
| **API** | Podman (supports Docker CLI) | Docker Engine API |
| **DNS** | Built-in (Aardvark-dns) | External (needs bridge network) |
| **Daemon** | Daemonless (Rootless friendly) | Daemon-like |
| **Networking** | Native, closer to Linux kernel | Mimics Docker bridge networks |
| **Best Proxy Setup** | Host-bound or `podman-compose` | Containerized on shared network |

For your environment, **Podman** is generally preferred for its daemonless, rootless-friendly architecture on standard Linux distributions, while **Kiri** is better if you have existing tooling that strictly expects the Docker Engine API.

Chatbot App is AI and can make mistakes. Check important information.

Add Anything

Drop your files here