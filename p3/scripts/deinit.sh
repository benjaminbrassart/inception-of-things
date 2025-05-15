#!/usr/bin/env sh

set -e

k3d cluster delete -a
rm -f -- "$(which k3d)" "$(which argocd)"

docker system prune -f
apt-get remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

rm -f \
    /etc/apt/keyrings/docker.asc \
    /etc/apt/sources.list.d/docker.list \
    /etc/profile.d/kubectl.sh \
    /usr/local/bin/argocd
