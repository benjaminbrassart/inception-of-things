#!/usr/bin/env sh

set -e

config_files='app1.yaml app2.yaml app3.yaml ingress.yaml'

for file in ${config_files}; do
    kubectl apply -f "${file}"
done
