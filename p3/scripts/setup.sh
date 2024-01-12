#!/usr/bin/env bash

if [[ "$(id -u)" -ne 0 ]]; then
    printf -- 'Please execute this script as root.\n' >&2
    exit 1
fi

set -e

MASTER_ADDRESS="$(ip -4 -o addr list enp0s3 | awk '{ print $4 }' | cut -d '/' -f 1)"
OS_ARCH="$(dpkg --print-architecture)"
OS_RELEASE="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
KEYRING_DIR='/etc/apt/keyrings'
DOCKER_GPG_KEY="${KEYRING_DIR}/docker.gpg"
NAMESPACE_ARGOCD='argocd'
NAMESPACE_APP='dev'
ARGOCD_APP_REPO='https://github.com/benjaminbrassart/estoffel-bbrassar.git'

printf -- '---> Docker\n'

apt-get update -y
apt-get install -y ca-certificates curl gnupg

mkdir -vp "${KEYRING_DIR}"
curl -fsSL 'https://download.docker.com/linux/ubuntu/gpg' | \
    gpg --yes --dearmor -o "${DOCKER_GPG_KEY}"
chmod a+r "${DOCKER_GPG_KEY}"

echo "deb [arch=${OS_ARCH} signed-by=${DOCKER_GPG_KEY}] https://download.docker.com/linux/ubuntu ${OS_RELEASE} stable" | \
    tee /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

usermod -aG docker "${USER}"

docker run hello-world

printf -- '---> K3S\n'

curl -fsL 'https://get.k3s.io' | \
    INSTALL_K3S_EXEC="server --cluster-init --bind-address=${MASTER_ADDRESS} --node-ip=${MASTER_ADDRESS}" \
    K3S_KUBECONFIG_MODE=644 \
    sh -

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

printf -- '---> K3D\n'

curl -fsL 'https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh' | bash -

printf -- '---> Argo CD\n'

kubectl create namespace "${NAMESPACE_APP}"
kubectl create namespace "${NAMESPACE_ARGOCD}"
kubectl apply -n "${NAMESPACE_ARGOCD}" -f 'https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml'

argo_tmp="$(mktemp)"

curl -sSL -o "${argo_tmp}" https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
install -m 555 "${argo_tmp}" /usr/local/bin/argocd
rm -f "${argo_tmp}"
unset argo_tmp

kubectl wait -n "${NAMESPACE_ARGOCD}" --for='condition=available' deployment --all --timeout=-1s

kubectl patch svc argocd-server -n "${NAMESPACE_ARGOCD}" -p '{"spec": {"type": "LoadBalancer"}}'

kubectl config set-context --current --namespace="${NAMESPACE_ARGOCD}"

argocd login --core --insecure

argocd app create playground \
    --repo "${ARGOCD_APP_REPO}" \
    --path . \
    --dest-server 'https://kubernetes.default.svc' \
    --dest-namespace "${NAMESPACE_APP}"

argocd app sync playground

kubectl wait -n "${NAMESPACE_APP}" --for='condition=available' deployment --all --timeout=-1s

argo_password="$(kubectl get secrets argocd-initial-admin-secret -o jsonpath='{ .data.password }' | base64 -d)"

printf -- '--------------------------------------------\n'
printf -- '\n'
printf -- '  Argo CD admin password: %s\n' "${argo_password}"
printf -- '\n'
printf -- '--------------------------------------------\n'

# -r        do not use backslash as inhibitor
# -s        do not print input
# -n 1      number of characters to read
# -p ...    prompt value
read -rs -n 1 -p 'Press a key to continue... '
printf -- '\n'

kubectl port-forward svc/argocd-server -n "${NAMESPACE_ARGOCD}" 8080:443 &

printf -- '\n'
printf -- '- Playground app: http://localhost:8888\n'
printf -- '- Argo CD dashboard: http://localhost:8080\n'
