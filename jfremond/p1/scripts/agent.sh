#!/bin/sh

# Turn on debug (print steps in terminal)
set -x

# Update and install curl
apt-get update && \
apt-get install -y curl

# Get K3s installation script
# Configure K3S to install as an agent node
# Run the script from standard input
# Set the server to connect to
# Authenticate the agent with the token set by the server
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent" sh -s - --server \
https://192.168.56.110:6443 --node-ip 192.168.56.111 --token 12345
