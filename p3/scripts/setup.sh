#!/usr/bin/env sh

set -e

kubectl create namespace dev
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

argocd login --core --insecure

# https://stackoverflow.com/a/68495551
initial_password="$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"

kubectl -n argocd delete secret argocd-initial-admin-secret

# https://argo-cd.readthedocs.io/en/stable/getting_started/#creating-apps-via-cli
kubectl config set-context --current --namespace=argocd
argocd app create playground \
    --repo https://github.com/benjaminbrassart/iot-p3-bbrassar.git \
    --file playground.yml \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace dev

cat <<EOF
===========================================================

    ArgoCD initial password: ${initial_password}

===========================================================
EOF
