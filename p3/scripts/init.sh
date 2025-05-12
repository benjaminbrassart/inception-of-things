#!/usr/bin/env sh

set -e

# Install docker
apt-get -y update
apt-get install -y ca-certificates curl

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

os_arch="$(dpkg --print-architecture)"
os_release="$(. /etc/os-release && echo "${VERSION_CODENAME}")"

printf -- 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian %s stable' "${os_arch}" "${os_release}" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get -y update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

docker run hello-world > /dev/null

# TODO install k3s
# TODO install k3d
# TODO add k=kubectl alias
