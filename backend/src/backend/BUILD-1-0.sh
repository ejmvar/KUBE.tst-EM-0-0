#!/bin/bash

docker build -t joke-app:1.0 .

docker images localhost/joke-app
podman images localhost/joke-app
