#!/usr/bin/env sh

curl -sfL 'https://get.k3s.io' | K3S_URL='https://bbrassarS:6443' K3S_TOKEN_FILE='/vagrant/k3s_token' sh -
