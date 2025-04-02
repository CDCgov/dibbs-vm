#!/bin/bash
# This script installs Docker on an Ubuntu server.
# 1. Updates the package list.
# 2. Creates the directory /etc/apt/keyrings with the appropriate permissions.
# 3. Downloads the Docker GPG key and saves it to /etc/apt/keyrings/docker.asc.
# 4. Sets the appropriate permissions for the Docker GPG key.
# 5. Adds the Docker repository to the APT sources list.
# 6. Updates the package list again to include the Docker repository.
# 7. Installs Docker packages including docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, and docker-compose-plugin.

# Install Docker
echo "post-install"
apt update
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
