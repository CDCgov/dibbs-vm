# Adjust Docker group permissions.
groupadd docker
usermod -aG docker ubuntu
newgrp docker

# Set Docker as system service and enable container autostart
systemctl enable docker.service
systemctl enable containerd.service
systemctl start docker.service

# Clone Compose files
cd ~
mkdir dev
cd dev
git clone https://github.com/CDCgov/dibbs-vm.git
cd dibbs-vm/docker/ecr-viewer

# Trigger initial docker compose to pull image data
docker compose up -d