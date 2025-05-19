#!/usr/bin/env sh

set -e

tmp="$(mktemp -d)"

trap 'rm -rf "${tmp}"' EXIT

k3d_install_url="https://raw.githubusercontent.com/k3d-io/k3d/201b614ea6798f0ee9e75c63360eef891b36bb19/install.sh"
k3d_install_sha256="0f6bd9a3ab8ea8625843b21657a6538f117975bb2823b73200dc8b92ccc626de"
k3d_install="${tmp}/k3d_install.sh"

kubectl_url="https://dl.k8s.io/release/v1.33.1/bin/linux/amd64/kubectl"
kubectl_sha256="5de4e9f2266738fd112b721265a0c1cd7f4e5208b670f811861f699474a100a3"
kubectl="${tmp}/kubectl"

argocd_cli_url="https://github.com/argoproj/argo-cd/releases/download/v3.0.0/argocd-linux-amd64"
argocd_cli_sha256="f04034734240d300a5aae22bf248bca6151a786975c7106ccc080f3eae758171"
argocd_cli="${tmp}/argocd"

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

usermod -aG docker bbrassar

# Download k3d install script
curl -fsSL "${k3d_install_url}" -o "${k3d_install}"
# Download kubectl
curl -fsSL "${kubectl_url}" -o "${kubectl}"
# Download argocd cli
curl -fsSL "${argocd_cli_url}" -o "${argocd_cli}"

# Verify checksums
{
    printf -- '%s  %s\n' "${k3d_install_sha256}" "${k3d_install}"
    printf -- '%s  %s\n' "${kubectl_sha256}" "${kubectl}"
    printf -- '%s  %s\n' "${argocd_cli_sha256}" "${argocd_cli}"
} | sha256sum -c -

chmod +x "${k3d_install}" "${argocd_cli}"

# Install k3d
"${k3d_install}"

# Install kubectl
install -m 0755 "${kubectl}" /usr/local/bin/kubectl

# Install argocd
install -m 0755 "${argocd_cli}" /usr/local/bin/argocd

# Create kubectl alias
ln -vfs /usr/local/bin/kubectl /usr/local/bin/k
