#!/usr/bin/env sh

set -e

k3d cluster create bonus \
    --kubeconfig-update-default --kubeconfig-switch-context \
    --port 18888:30080@server
