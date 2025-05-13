#!/usr/bin/env sh

kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 8080:443 &
kubectl port-forward svc/playground -n dev --address 0.0.0.0 8888:8888 &

wait
