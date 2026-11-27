---
title: "pabpereza/toolkitbox: Container images to wrap different database clients, utilities and toolbox to use it on docker, podman, Kubernetes o everywhere."
source: "https://github.com/pabpereza/toolkitbox"
author:
published:
created: 2026-11-27
description:
tags:
  - "clippings"
---
## Toolkitbox

A modular Docker image build system for DevOps/SysAdmin tools and clients. You can use a single image with all tools included, individual images per tool, or bundles grouped by kind of tool.

> 📢 **Found an issue or want to request a new tool?** [Open an issue on GitHub](https://github.com/pabpereza/toolkitbox/issues)

## Available Images

### Bundle Images

| Image | Description | Components | Size | Docker Pull | Badges |
| --- | --- | --- | --- | --- | --- |
| all | All tools in one image | all components | 351.0 MB | `docker pull toolkitbox/all` |  |
| cloud | Cloud Bundle | aws-cli, azure-cli, gcloud | 290.7 MB | `docker pull toolkitbox/cloud` |  |
| databases | Databases Bundle | postgres, mysql, mariadb, mongo, redis, sqlite | 71.3 MB | `docker pull toolkitbox/databases` |  |

### Individual Tools

| Tool | Versions | Size | Docker Pull | Badges |
| --- | --- | --- | --- | --- |
| aws-cli | `latest`,`v1` | 47.4 MB | `docker pull toolkitbox/aws-cli` |  |
| azure-cli | `latest` | 137.0 MB | `docker pull toolkitbox/azure-cli` |  |
| duckdb | `v1.4.4` | \- | `docker pull toolkitbox/duckdb` |  |
| gcloud | `latest` | 152.7 MB | `docker pull toolkitbox/gcloud` |  |
| mariadb | `latest`,`v10.3`,`v10.4` | 17.7 MB | `docker pull toolkitbox/mariadb` |  |
| mongo | `latest`,`v3.6`,`v4.4` | 53.1 MB | `docker pull toolkitbox/mongo` |  |
| mysql | `latest`,`v5.6`,`v5.7` | 17.7 MB | `docker pull toolkitbox/mysql` |  |
| postgres | `latest`,`v10`,`v11`,`v9.6` | 11.6 MB | `docker pull toolkitbox/postgres` |  |
| redis | `latest`,`v4`,`v5` | 8.9 MB | `docker pull toolkitbox/redis` |  |
| sqlite | `latest`,`v3` | 8.1 MB | `docker pull toolkitbox/sqlite` |  |

### Standalone Only (Not in Bundles)

Some tools require glibc and cannot be included in Alpine-based bundles:

| Tool | Reason | Available As |
| --- | --- | --- |
| duckdb | Requires glibc (Alpine uses musl) | Standalone image only |

## Overview

This system allows you to dynamically build a "mega image" containing multiple tools without manually editing Dockerfiles. Simply add a new component directory with an `install.sh` script, and the orchestrator automatically includes it in the build.

This repository builds an individual image for each component as well, allowing for flexible usage and an all-in-one image.

## Architecture

The Dynamic Injection pattern works as follows:

1. **Component Discovery**: The orchestrator scans the `components/` directory for tools
2. **Script Collection**: Each component's `install.sh` is copied to a temporary build context
3. **Dynamic Installation**: The Dockerfile iterates through all collected scripts and executes them
4. **Clean Build**: Temporary files are removed to keep the final image lean

## Project Structure

```
.gitignore                   # Ignores .build-context directory
build-mega-image.sh          # Orchestrator script (main entry point)
build-single.sh              # Script to build individual component images
Dockerfile.bundle            # Generic Dockerfile for mega image
components/                  # Component library
├── postgres/
│   ├── install.sh           # Latest PostgreSQL client installer
│   └── v11-legacy/          # Legacy version (not included in bundle)
│       └── Dockerfile       # Standalone Dockerfile for PG 11
└── aws-cli/
└── install.sh           # AWS CLI installer
```

## Quick Start

### Building the all-in-one Image

```
./build-all-in-one.sh
```

The script will:

- Discover all components with `install.sh` files
- Create a temporary `.build-context` directory
- Copy and rename component installers (e.g., `postgres.sh`, `aws-cli.sh`)
- Build the Docker image tagged as `ops-toolchain:latest`

## Adding New Components

To add a new tool to the mega image:

1. Create a new directory under `components/`:

	```
	mkdir components/my-tool
	```
2. Create an `install.sh` script:

	```
	cat > components/my-tool/install.sh <<'EOF'
	#!/bin/bash
	set -e
	
	echo "Installing my-tool..."
	apk add --no-cache my-tool
	
	# Verify installation
	if command -v my-tool &> /dev/null; then
	    echo "my-tool installed successfully"
	else
	    echo "ERROR: my-tool installation failed"
	    exit 1
	fi
	EOF
	```
3. Rebuild the all-in-one image:

	```
	./build-allinone.sh
	```

That's it! No Dockerfile editing required.

## Automated Docker Hub Description Sync

This repository includes an automated workflow that keeps Docker Hub image descriptions synchronized with component READMEs.

### Workflow: sync-dockerhub-descriptions.yml

**Triggers:**

- Automatically when `components/**/README.md` files are updated in the `main` branch
- Manually via GitHub Actions UI (workflow\_dispatch)

**Functionality:**

1. Authenticates with Docker Hub API
2. Iterates through all components in `components/` directory
3. Updates the Docker Hub description for each image using its README.md content

**Requirements:**

- `DOCKER_TOKEN` secret must be configured in repository settings
- Docker Hub repositories must exist before running the workflow

### Updating Component Descriptions

To update a Docker Hub image description:

1. Edit the component's README: `components/{component}/README.md`
2. Commit and push to the `main` branch
3. The workflow will automatically sync the description to Docker Hub

The workflow uses the entire README content as the "full description" on Docker Hub, preserving all markdown formatting.

## Contributing

When adding new components:

1. Follow the component guidelines above
2. Test the installation script in isolation first
3. Verify the individual and all-in-one image builds successfully
4. Update documentation if adding complex components
5. Create a comprehensive README.md in the component directory (it will be synced to Docker Hub)