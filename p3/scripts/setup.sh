#!/usr/bin/env sh

set -e

k3d cluster create p3 \
    --kubeconfig-update-default --kubeconfig-switch-context \
    --agents 1 \
    --port 8888:30080@agent:0

kubectl create namespace dev
kubectl create namespace argocd
kubectl apply --namespace argocd --filename https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl wait pods --all --for condition=Ready --namespace argocd --timeout -1s

argocd login --core --insecure

# https://stackoverflow.com/a/68495551
initial_password="$(kubectl --namespace argocd get secret argocd-initial-admin-secret --output jsonpath="{.data.password}" | base64 -d)"

# https://argo-cd.readthedocs.io/en/stable/getting_started/#creating-apps-via-cli
kubectl config set-context --current --namespace argocd
argocd app create playground \
    --repo https://github.com/benjaminbrassart/iot-p3-bbrassar.git \
    --path . \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace dev \
    --sync-policy auto \
    --auto-prune \
    --self-heal

cat <<EOF
===========================================================

    Argo CD initial password: ${initial_password}

===========================================================
EOF
