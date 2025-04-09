#!/usr/bin/env sh

set -e

kubectl apply -f conf/app1.yaml
kubectl apply -f conf/app2.yaml
kubectl apply -f conf/app3.yaml
kubectl apply -f conf/ingress.yaml
