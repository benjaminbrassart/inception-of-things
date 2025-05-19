#!/usr/bin/env sh

kubectl delete namespace argocd dev
k3d cluster delete p3
