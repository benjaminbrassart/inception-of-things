#!/usr/bin/env sh

set -e

INIT_USER="$(whoami)"
export INIT_USER

# Install docker
sudo sh -c <<-'EOF'
set -e

apt-get -y update
apt-get install -y ca-certificates curl

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

os_arch="$(dpkg --print-architecture)"
os_release="$(. /etc/os-release && echo "$VERSION_CODENAME")"

printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian %s stable' -- "${os_arch}" "${os_release}" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get -y update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

usermod -aG docker "${INIT_USER}"
EOF

# TODO install k3s
# TODO install k3d
# TODO add k=kubectl alias
