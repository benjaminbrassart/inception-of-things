#!/usr/bin/env sh

set -e

GITOPS_REPO_URL='https://github.com/benjaminbrassart/estoffel-bbrassar.git'

update_pkgs() {
    apt-get update
}

install_pkg() {
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
    update_pkgs
    install_pkg ca-certificates curl gnupg

    add_gpg_key
    add_docker_repo

    update_pkgs
    install_pkg docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    add_docker_group vagrant

    docker run hello-world > /dev/null
}

install_k3s() {
    update_pkgs
    install_pkg curl

    master_address="$1"

    curl -sfL "https://get.k3s.io" | \
        INSTALL_K3S_EXEC="server --cluster-init --bind-address=${master_address} --node-ip=${master_address}" \
        K3S_KUBECONFIG_MODE="644" \
        sh -

    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
}

install_k3d() {
    install_pkg curl

    curl -sfL "https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh" | bash -
}

# Mostly copy-paste from here: https://argo-cd.readthedocs.io/en/release-2.9/getting_started/
install_argocd() {
    argocd_namespace="$1"
    app_namespace="dev"

    kubectl create namespace "${argocd_namespace}"
    kubectl apply -n "${argocd_namespace}" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    kubectl create namespace "${app_namespace}"

    argocd_tmp="$(mktemp)"

    curl -sSL -o "${argocd_tmp}" https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    install -m 555 "${argocd_tmp}" /usr/local/bin/argocd
    rm -f "${argocd_tmp}"

    kubectl patch svc argocd-server \
        -n "${argocd_namespace}" \
        -p '{"spec": {"type": "LoadBalancer"}}'

    kubectl wait -n "${argocd_namespace}" --for='condition=available' deployment --all --timeout=-1s

    kubectl config set-context \
        --current \
        --namespace="${argocd_namespace}"

    argocd login --core --insecure

    argocd app create playground \
        --repo "${GITOPS_REPO_URL}" \
        --path . \
        --dest-server https://kubernetes.default.svc \
        --dest-namespace "${app_namespace}"

    argocd app set playground --sync-policy automated

    argocd app sync playground

    kubectl wait -n "${app_namespace}" --for='condition=available' deployment --all --timeout=-1s

    # TODO find why port forwarding always crashes after some time
}

set -x

printf -- "---> Docker\n"
install_docker
printf -- "---> K3S\n"
install_k3s "192.168.56.110"
printf -- "---> K3D\n"
install_k3d
printf -- "---> Argo CD\n"
install_argocd argocd
printf -- "---> OK\n"
