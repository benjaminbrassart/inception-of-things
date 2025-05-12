#!/usr/bin/env sh

set -e

tmp="$(mktemp -d)"

trap 'rm -rf "${tmp}"' EXIT

k3s_install_url="https://raw.githubusercontent.com/k3s-io/k3s/079ffa8d99fb859cb8c001455e47efa65535d832/install.sh"
k3s_install_sha256="d75e014f2d2ab5d30a318efa5c326f3b0b7596f194afcff90fa7a7a91166d5f7"
k3s_install="${tmp}/k3s_install.sh"

k3d_install_url="https://raw.githubusercontent.com/k3d-io/k3d/201b614ea6798f0ee9e75c63360eef891b36bb19/install.sh"
k3d_install_sha256="0f6bd9a3ab8ea8625843b21657a6538f117975bb2823b73200dc8b92ccc626de"
k3d_install="${tmp}/k3d_install.sh"

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

docker run hello-world > /dev/null

usermod -aG docker bbrassar

node_ip4="$(hostname -I | cut -d ' ' -f 1)"

# Download k3s install script
curl -fsSL "${k3s_install_url}" -o "${k3s_install}"
# Download k3d install script
curl -fsSL "${k3d_install_url}" -o "${k3d_install}"
# Download argocd cli
curl -fsSL "${argocd_cli_url}" -o "${argocd_cli}"

# Verify checksums
{
    printf -- '%s  %s\n' "${k3s_install_sha256}" "${k3s_install}"
    printf -- '%s  %s\n' "${k3d_install_sha256}" "${k3d_install}"
    printf -- '%s  %s\n' "${argocd_cli_sha256}" "${argocd_cli}"
} | sha256sum -c -

chmod +x "${k3s_install}" "${k3d_install}" "${argocd_cli}"

# Install k3s
"${k3s_install}" \
    --cluster-init \
    --write-kubeconfig-mode=644 \
    --node-ip="${node_ip4}" \
    --bind-address="${node_ip4}"

# Install k3d
"${k3d_install}"

# Install argocd
install -m 755 "${argocd_cli}" /usr/local/bin/argocd

# Create kubectl alias
printf -- 'alias k=kubectl\n' > /etc/profile.d/kubectl.sh
