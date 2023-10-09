#!/usr/bin/env sh

curl -sfL https://get.k3s.io | sh -
cp /etc/rancher/k3s/k3s.yaml /vagrant/kubeconfig
