#!/bin/bash

# loop through all .env files and export the variables
for file in $(find . -name "*.env"); do
  export $(cat $file | xargs)
done

# Adjust Docker group permissions.
groupadd docker
usermod -aG docker ubuntu
newgrp docker

# Set Docker as system service and enable container autostart
systemctl enable docker.service
systemctl enable containerd.service
systemctl start docker.service

# Check if DIBBS_SERVICE is valid
# dibbs-ecr-viewer
# dibbs-query-connect
if [ "$DIBBS_SERVICE" == "dibbs-ecr-viewer" ] || [ "$DIBBS_SERVICE" == "dibbs-query-connect" ]; then
  echo "DIBBS Service is valid. DIBBS_SERVICE=$DIBBS_SERVICE"
else
  echo "DIBBS Service is not valid. DIBBS_SERVICE=$DIBBS_SERVICE" && exit 1
fi

# Clone the dibbs-vm repository
git clone --branch alis/21_2 https://github.com/CDCgov/dibbs-vm.git
# cd "dibbs-vm/docker/$(echo "$DIBBS_SERVICE" | sed -E 's/.*?dibbs-//')" || exit
cd "dibbs-vm/docker/$DIBBS_SERVICE"

# Trigger initial docker compose to pull image data
docker compose up -d