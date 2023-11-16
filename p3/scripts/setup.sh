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
    curl -fsSL "https://download.docker.com/linux/debian/gpg" | \
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

install_docker() {
    update
    install ca-certificates curl gnupg

    add_gpg_key
    add_docker_repo

    update
    install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    add_docker_group vagrant

    docker run hello-world > /dev/null
}

install_k3s() {
    update
    install curl

    master_address="$1"

    curl -sfL "https://get.k3s.io" | \
        INSTALL_K3S_EXEC="server --cluster-init --bind-address=${master_address} --node-ip=${master_address}" \
        K3S_KUBECONFIG_MODE="644" \
        sh -
}

install_k3d() {
    install curl

    curl -sfL "https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh" | bash -
}

printf -- "---> Docker\n"
install_docker
printf -- "---> K3S\n"
install_k3s "192.168.56.110"
printf -- "---> K3D\n"
install_k3d
printf -- "---> OK\n"
