#!/bin/sh

# Turn on debug (print steps in terminal)
set -x

# Create new k3d cluster
k3d cluster create \
	--port "8888:30080@server:0"

# Create namespaces for deployment and installation of Argo CD
kubectl create namespace dev
kubectl create namespace argocd

# Install Argo CD in 'argocd' namespace
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.11/manifests/install.yaml

# Wait for all Argo CD pods to be ready before continuing
kubectl wait pod --all --for=condition=Ready --namespace=argocd --timeout -1s

# Install ArgoCD cli
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Login into Argo CD API server
argocd login --core

# Create app via CLI
# Set default namespace to argocd
kubectl config set-context --current --namespace=argocd

# Create new Argo CD app called 'iot'
argocd app create iot \
  --repo https://github.com/jfremond/k3d-repo.git \
  --path . \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev

# Set the app to automatically sync and self-heal, with auto-prune
argocd app set iot --sync-policy automated --auto-prune --self-heal

# Wait for the app to be synced and healthy
argocd app wait iot --sync

# Decode initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port Forwarding
kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8080:443
