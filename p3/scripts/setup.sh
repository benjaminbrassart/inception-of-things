#!/usr/bin/env sh

set -e

update() {
    apt-get update
}

install() {
    apt-get install -y -- "$@"
}

add_gpg_key() {
    keyring_dir="/etc/apt/keyrings"
    docker_gpg_key="${keyring_dir}/docker.gpg"

    mkdir -vp "${keyring_dir}"
    curl -fsSL 'https://download.docker.com/linux/debian/gpg' | \
        gpg --yes --dearmor -o "${docker_gpg_key}"
    chmod a+r "${docker_gpg_key}"
}

get_release() {
    . /etc/os-release

    echo "${VERSION_CODENAME}"
}

add_docker_repo() {
    arch="$(dpkg --print-architecture)"
    release="$(get_release)"

    echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian ${release} stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null
}

add_docker_group() {
    for user in "$@"; do
        usermod -aG docker "${user}"
    done
}

printf -- "---> Docker\n"

update
install ca-certificates curl gnupg

add_gpg_key
add_docker_repo

update
install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

add_docker_group vagrant

docker run hello-world > /dev/null

printf -- "---> OK\n"
