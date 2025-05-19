#!/usr/bin/env sh

set -e

tmp="$(mktemp -d)"

trap 'rm -rf "${tmp}"' EXIT

helm_install_url="https://raw.githubusercontent.com/helm/helm/8eb615d37604294611d2fe4a3f39aa433d6fb7e9/scripts/get-helm-3"
helm_install_sha256="17799e1dddef4d63aa8bfd84ba58715f6668f099f738e02af094c8db2c148005"
helm_install="${tmp}/get-helm-3"

# Download helm install script
curl -fsSL "${helm_install_url}" -o "${helm_install}"

# Verify checksums
{
    printf -- '%s  %s\n' "${helm_install_sha256}" "${helm_install}"
} | sha256sum -c -

chmod +x "${helm_install}"

# Install helm
"${helm_install}"
