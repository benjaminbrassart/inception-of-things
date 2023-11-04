#!/usr/bin/env sh

set -x

apt-get update
apt-get install -y curl net-tools

echo "alias k=kubectl" >> /etc/profile

master_address="192.168.56.110"

export INSTALL_K3S_EXEC="server \
--cluster-init \
--bind-address='${master_address}' \
--node-ip='${master_address}' \
"

curl -sfL 'https://get.k3s.io' | K3S_KUBECONFIG_MODE='644' sh -
