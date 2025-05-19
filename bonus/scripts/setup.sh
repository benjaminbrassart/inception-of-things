#!/usr/bin/env sh

set -e
set -x

k3d cluster create bonus \
    --kubeconfig-update-default --kubeconfig-switch-context

helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd --namespace argocd --create-namespace argo/argo-cd
