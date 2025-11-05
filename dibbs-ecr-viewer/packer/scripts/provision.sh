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

export DEBIAN_FRONTEND=noninteractive

# Adjust Docker group permissions.
echo "[$(date)] Adjusting Docker group permissions."
groupadd docker
usermod -aG docker dibbs-user
newgrp docker

# Set Docker as system service and enable container autostart
echo "[$(date)] Enabling Docker and containerd services."
systemctl enable docker.service
systemctl enable containerd.service

if ! systemctl is-active --quiet docker.service; then
  echo "[$(date)] ERROR: Docker service failed to start."
  systemctl status docker.service
  journalctl -xeu docker.service | tail -40
  # Print Docker daemon log for more details
  if [ -f /var/log/docker.log ]; then
    echo "[$(date)] Showing last 40 lines of /var/log/docker.log:"
    tail -40 /var/log/docker.log
  else
    echo "[$(date)] Showing last 40 lines of Docker journal log:"
    journalctl -u docker.service | tail -40
  fi
  exit 4
fi

systemctl status docker.service

# Check if DIBBS_SERVICE is valid
# dibbs-ecr-viewer
echo "[$(date)] Validating DIBBS_SERVICE variable."
if [ "$DIBBS_SERVICE" == "dibbs-ecr-viewer" ] || [ "$DIBBS_SERVICE" == "dibbs-query-connector" ]; then
  echo "[$(date)] DIBBS Service is valid. DIBBS_SERVICE=$DIBBS_SERVICE"
else
  echo "[$(date)] DIBBS Service is not valid. DIBBS_SERVICE=$DIBBS_SERVICE" && exit 1
fi

# Clone the dibbs-vm repository
echo "[$(date)] Cloning dibbs-vm repository to /home/dibbs-user."
cd /home/dibbs-user || exit
git clone https://github.com/CDCgov/dibbs-vm.git
cd "/home/dibbs-user/dibbs-vm/$DIBBS_SERVICE" || exit

# ensures the DIBBS variables are set and accessible to the wizard
echo "[$(date)] Setting DIBBS variables in env file."
echo "DIBBS_SERVICE=$DIBBS_SERVICE" >>"$DIBBS_SERVICE.env"
echo "DIBBS_VERSION=$DIBBS_VERSION" >>"$DIBBS_SERVICE.env"
echo "" >>"$DIBBS_SERVICE.env"

# export only the DIBBS_SERVICE and DIBBS_VERSION from the '$HOME/dibbs-vm/"$DIBBS_SERVICE"/*.env' file
echo "[$(date)] Exporting DIBBS_SERVICE and DIBBS_VERSION to .bashrc."
echo 'export $(cat '/home/dibbs-user/dibbs-vm/"$DIBBS_SERVICE"/"$DIBBS_SERVICE".env' | grep DIBBS_SERVICE= | xargs)' >>"/home/dibbs-user/.bashrc"
echo 'export $(cat '/home/dibbs-user/dibbs-vm/"$DIBBS_SERVICE"/"$DIBBS_SERVICE".env' | grep DIBBS_VERSION= | xargs)' >>"/home/dibbs-user/.bashrc"

mv ~/"$DIBBS_SERVICE"-wizard.sh /home/dibbs-user/"$DIBBS_SERVICE"-wizard.sh
mv ~/hot-upgrade.sh /home/dibbs-user/hot-upgrade.sh
mv ~/apt-updates.sh /home/dibbs-user/apt-updates.sh
chmod +x /home/dibbs-user/"$DIBBS_SERVICE"-wizard.sh
chmod +x /home/dibbs-user/hot-upgrade.sh
chmod +x /home/dibbs-user/apt-updates.sh

# Gives ubuntu user ownership of the dibbs-vm directory
echo "[$(date)] Changing ownership of dibbs-vm directory."
chown -R dibbs-user:dibbs-user "/home/dibbs-user/dibbs-vm"

# Trigger initial docker compose commands to construct container stack
echo "[$(date)] Running initial docker compose build and up."
if ! command -v docker &>/dev/null; then
  echo "[$(date)] ERROR: Docker is not installed or not in PATH. Exiting."
  exit 2
fi

if ! docker info &>/dev/null; then
  echo "[$(date)] ERROR: Docker daemon is not running. Exiting."
  exit 3
fi

docker info
docker compose build
docker compose up -d
echo "[$(date)] DIBBS provision script completed."

sudo userdel -rf ubuntu
sleep 60
