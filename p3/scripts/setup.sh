#!/usr/bin/env sh

set -e

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

argocd login --core --insecure

# https://stackoverflow.com/a/68495551
initial_password="$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"

kubectl -n argocd delete secret argocd-initial-admin-secret

kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8080:443

printf -- 'ArgoCD initial password: %s\n' "${initial_password}"
