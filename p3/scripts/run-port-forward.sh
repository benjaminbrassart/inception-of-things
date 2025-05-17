#!/usr/bin/env sh

kubectl port-forward svc/argocd-server --namespace argocd --address 0.0.0.0 8080:443
