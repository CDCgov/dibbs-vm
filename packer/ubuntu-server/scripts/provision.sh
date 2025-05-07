#!/bin/bash
# This script provisions an Ubuntu server for the DIBBS project by performing the following steps:
# 1. Exports environment variables from all .env files in the current directory and its subdirectories.
# 2. Adjusts Docker group permissions by adding the 'docker' group and adding the 'ubuntu' user to it.
# 3. Sets Docker as a system service and enables container autostart.
# 4. Validates the DIBBS_SERVICE environment variable to ensure it is either 'dibbs-ecr-viewer' or 'dibbs-query-connector'.
# 5. Clones the 'dibbs-vm' repository from GitHub and navigates to the appropriate service directory.
# 6. Ensures the DIBBS_SERVICE and DIBBS_VERSION variables are set and accessible to the wizard by appending them to the service's .env file.
# 7. Enables Docker Compose variables to stay set on reboot by appending the export command to the .bashrc file.
# 8. Changes ownership of the 'dibbs-vm' directory to the 'ubuntu' user.
# 9. Triggers an initial Docker Compose to pull image data and start the containers.

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
# dibbs-query-connector
if [ "$DIBBS_SERVICE" == "dibbs-ecr-viewer" ] || [ "$DIBBS_SERVICE" == "dibbs-query-connector" ]; then
  echo "DIBBS Service is valid. DIBBS_SERVICE=$DIBBS_SERVICE"
else
  echo "DIBBS Service is not valid. DIBBS_SERVICE=$DIBBS_SERVICE" && exit 1
fi

# Clone the dibbs-vm repository
git clone --branch shanice/qc-revised https://github.com/CDCgov/dibbs-vm.git
cd "$HOME/dibbs-vm/$DIBBS_SERVICE"

# ensures the DIBBS variables are set and accessible to the wizard
echo "DIBBS_SERVICE=$DIBBS_SERVICE" >> "$DIBBS_SERVICE.env"
echo "DIBBS_VERSION=$DIBBS_VERSION" >> "$DIBBS_SERVICE.env"
echo "" >> "$DIBBS_SERVICE.env"

# enables docker compose variables to stay set on reboot, DIBBS_SERVICE and DIBBS_VERSION
echo 'export $(cat '$HOME/dibbs-vm/"$DIBBS_SERVICE"/*.env' | xargs)' >> "$HOME"/.bashrc

# Gives ubuntu user ownership of the dibbs-vm directory and permission to execute wizard script
chown -R ubuntu:ubuntu "$HOME/dibbs-vm"
chmod +x "$DIBBS_SERVICE-wizard.sh"

# Trigger initial docker compose commands to construct container stack
docker compose build
docker compose up -d