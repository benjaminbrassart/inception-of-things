#!/usr/bin/env sh

set -e
set -x

helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd --namespace argocd --create-namespace argo/argo-cd
