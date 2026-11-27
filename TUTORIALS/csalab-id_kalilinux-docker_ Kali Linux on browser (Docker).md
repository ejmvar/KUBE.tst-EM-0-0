---
title: "csalab-id/kalilinux-docker: Kali Linux on browser (Docker)"
source: "https://github.com/csalab-id/kalilinux-docker"
author:
published:
created: 2026-11-27
description:
tags:
  - "clippings"
---
## Kali Linux Desktop on the Browser

This repository contains a Docker Compose application that runs a Kali Linux desktop accessible through your web browser via NoVNC.

[![Screenshot](https://github.com/csalab-id/kalilinux-docker/raw/main/.github/images/screenshoot.png)](https://github.com/csalab-id/kalilinux-docker/blob/main/.github/images/screenshoot.png)

## Description

This Docker Compose application provides:

- **Kali Linux**: A web server running NoVNC with Kali Linux Desktop environment.
	- Default password: `kalilinux`
	- Default exposed port: `8080`

## Requirements

To run this application, you need:

- Docker Engine
- Docker Compose

## Usage

### Quick Start

1. Clone the repository:

	```
	git clone https://github.com/csalab-id/kalilinux-docker.git
	```
2. Navigate to the repository directory:

	```
	cd kalilinux-docker
	```
3. Pull the required Docker images:

	```
	docker compose pull
	```
4. Set a custom password for the environment (optional):

	```
	export PASSWORD="YourVNCPassword"
	```
5. Start the containers in detached mode:

	```
	docker compose up -d
	```
6. Access the web application at: [http://localhost:8080/vnc.html](http://localhost:8080/vnc.html)

## Environment Variables

You can customize the application using these environment variables:

| Variable | Description | Default |
| --- | --- | --- |
| `PASSWORD` | VNC password | `kalilinux` |
| `BIND` | Address and port to bind the server (format: IP:PORT) | `0.0.0.0:8080` |

Example usage:

```
export PASSWORD="mysecretpassword"
export BIND="0.0.0.0:9090"
docker compose up -d
```

## License

This Docker Compose application is released under the MIT License. See the [LICENSE](https://www.mit.edu/~amini/LICENSE.md) file for details.

## Disclaimer

The software developed and distributed for hacking purposes is intended for **educational and testing purposes only**. The use of this software for any illegal activity is strictly prohibited. The developers and distributors of the software are not liable for any damages or legal consequences resulting from the misuse of the software.