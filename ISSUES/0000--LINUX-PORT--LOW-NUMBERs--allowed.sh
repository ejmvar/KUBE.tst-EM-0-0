#!/bin/bash

# === See current LOW PORT setting:
sysctl net.ipv4.ip_unprivileged_port_start

# ❯ sysctl net.ipv4.ip_unprivileged_port_start
# net.ipv4.ip_unprivileged_port_start = 1024


# === Select external ports                                                           
# !!! PORT: OPTION 1: Allow priviledged port 80 for podman:
# Apply immediately (no reboot needed)
sudo sysctl -w net.ipv4.ip_unprivileged_port_start=80
# Make it permanent
echo 'net.ipv4.ip_unprivileged_port_start=80' | sudo tee -a /etc/sysctl.conf


