#!/usr/bin/env bash
#!/bin/bash
set -u

echo "# Server start ------------------------------"
timeout 20 uv run backend/src/backend/app.py &

echo "# Server wait ------------------------------"
sleep 1

echo "# Server test ------------------------------"
# Actual request
curl -v http://localhost:8080

echo "# Server finishing ------------------------------"
