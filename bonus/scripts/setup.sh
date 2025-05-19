#!/usr/bin/env sh

set -e
set -x

helm repo add gitlab https://charts.gitlab.io/
helm install gitlab --create-namespace --namespace gitlab gitlab/gitlab \
    --set installCertmanager=false \
    --set global.ingress.configureCertmanager=false \
    --set gitlab-runner.install=false
