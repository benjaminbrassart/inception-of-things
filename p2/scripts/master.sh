#!/bin/sh

# Turn on debug (print steps in terminal)
set -x

# Update and install curl
apt-get update && \
apt-get install -y curl

# Get K3s installation script
# Configure K3S to install and run as a server node
# Run the script from standard input
# Set token to be used by agents to join cluster
# Specify the IP address the node should use in the cluster
# Initialize a new cluster
# Allow non-root users to read kubeconfig file
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -s - --token 12345 --node-ip 192.168.56.110 --cluster-init --write-kubeconfig-mode=644

# Create an alias for kubectl
if [ ! -f .bash_aliases ]; then
	touch .bash_aliases
	echo alias k='kubectl' > .bash_aliases
fi

# Apply the configuration to a pod
kubectl apply -f ./confs/
