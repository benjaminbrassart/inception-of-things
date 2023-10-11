#!/usr/bin/env sh

curl -sfL 'https://get.k3s.io' | sh -
cp /etc/rancher/k3s/k3s.yaml /vagrant/kubeconfig
cp /var/lib/rancher/k3s/server/token /vagrant/k3s_token
