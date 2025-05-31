#!/bin/sh

# Turn on debug (print steps in terminal)
set -x

# Update
sudo apt-get update

# Install required packages
sudo apt-get install -y ca-certificates curl

# Install Docker's GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc

# Set correct permissions
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update again to include Docker's packages
sudo apt-get update

# Install Docker Engine, CLI, containerd, and official plugins
sudo apt-get install -y docker-ce \
                        docker-ce-cli \
                        containerd.io \
                        docker-buildx-plugin \
                        docker-compose-plugin

# Give docker role to jfremond
sudo usermod -aG docker jfremond
