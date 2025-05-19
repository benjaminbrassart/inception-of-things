#!/usr/bin/env sh

helm uninstall gitlab --namespace gitlab
helm repo remove gitlab
