#!/bin/sh

# Turn on debug (print steps in terminal)
set -x

# Install curl and get
sudo apt-get update
sudo apt-get install -y wget curl

# Doanwload and install curent latest version of k3d
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Download latest stable version of kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

#Install kubectl with correct permissions
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Create local .bin directory and move kubectl there
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl

# Create an alias for kubectl
if [ ! -f ~/.bash_aliases ]; then
	touch ~/.bash_aliases
	echo alias k='kubectl' > ~/.bash_aliases
    . ~/.bashrc
fi
