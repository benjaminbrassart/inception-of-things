#!/usr/bin/env sh

set -x

master_address="192.168.56.110"

export INSTALL_K3S_EXEC="server \
--cluster-init \
--bind-address='${master_address}' \
--node-ip='${master_address}' \
"

curl -sfL 'https://get.k3s.io' | sh -

# yq -yi '.clusters[].cluster.server = "https://bbrassarS:6443"' /etc/rancher/k3s/k3s.yaml

# systemctl restart k3s

cp /etc/rancher/k3s/k3s.yaml /vagrant_shared/kubeconfig
cp /var/lib/rancher/k3s/server/token /vagrant_shared/k3s_token
