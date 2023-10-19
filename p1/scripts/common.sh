#!/usr/bin/env sh

set -x

apt-get update
apt-get install -y curl net-tools

echo "alias k=kubectl" >> ~/.bashrc
