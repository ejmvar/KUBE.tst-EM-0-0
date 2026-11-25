

B. Certificate Management (mkcert)

mkcert is highly reliable on Linux. The benefit here is that you can easily install the CA into your system trust store once:
bash

Collapse

 Copy

# Install dependencies (varies by distro)
sudo apt install libnss3-tools 

# Generate CA
mkcert -install

Your containers can then mount the generated certificates, and they will be "trusted" by browsers running on that same Linux machine (including headless browsers or CLI tools using curl or wget).
C. Reverse Proxy (The "Linux Way")

While you can use a containerized Caddy instance, on Linux, you also have the option of running the proxy directly on the host (e.g., installing Caddy via apt or binary).

    Host Proxy Benefit: Running the proxy on the host makes it easier to manage certificates across all containers and services without managing internal Docker/Kiri bridge networks.
    Container Proxy Benefit: Keeping the proxy in a container (Kiri/Podman) keeps your host environment clean and makes your development environment portable across different Linux machines/AMIs.
