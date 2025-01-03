#!/bin/bash

# Install Docker
apt-get update
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Adjust Docker group permissions
groupadd docker
usermod -aG docker ubuntu
newgrp docker

# Set Docker as system service and enable container autostart
systemctl enable docker.service
systemctl enable containerd.service

# Clone Compose files
cd ~
mkdir dev
cd dev
git clone https://github.com/CDCgov/dibbs-vm.git
cd dibbs-vm/docker/ecr-viewer

# Trigger initial docker compose to pull image data
docker compose up -d