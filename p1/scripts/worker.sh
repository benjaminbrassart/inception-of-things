#!/usr/bin/env sh

set -x

master_address="192.168.56.110"
node_address="192.168.56.111"

echo "${master_address}  bbrassarS" >> /etc/hosts

token="$(cat /vagrant_shared/k3s_token)"

export KUBECONFIG=/vagrant_shared/kubeconfig
export INSTALL_K3S_EXEC="agent \
--node-ip='${node_address}' \
--server='https://bbrassarS:6443' \
--token='${token}' \
"

curl -sfL 'https://get.k3s.io' | K3S_KUBECONFIG_MODE="644" sh -
