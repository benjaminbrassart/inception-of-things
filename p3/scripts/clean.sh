#!/usr/bin/env sh

kubectl delete ns argocd dev
k3d cluster delete iot
