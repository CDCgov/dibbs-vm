#!/bin/bash
# This script installs Docker on an Ubuntu server.
# 1. Updates the package list.
# 2. Creates the directory /etc/apt/keyrings with the appropriate permissions.
# 3. Downloads the Docker GPG key and saves it to /etc/apt/keyrings/docker.asc.
# 4. Sets the appropriate permissions for the Docker GPG key.
# 5. Adds the Docker repository to the APT sources list.
# 6. Updates the package list again to include the Docker repository.
# 7. Installs Docker packages including docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, and docker-compose-plugin.

#!/bin/bash

# Set default sudo behavior (empty means no sudo)
USE_SUDO="${USE_SUDO:-}"
# Set default sudo behavior (empty means no sudo)
USE_SUDO="${USE_SUDO:-}"
# Install Docker
echo "Starting post-install configuration..."
# Ensure package lists are updated
$USE_SUDO apt-get update

# Determine the build type based on environment variable
if [ "$BUILD_TYPE" == "aws" ]; then
    echo "Running AWS-specific Docker installation..."
    # Create keyring directory with proper permissions
    $USE_SUDO install -m 0755 -d /etc/apt/keyrings
    # Download and store Docker's GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $USE_SUDO tee /etc/apt/keyrings/docker.asc > /dev/null
    # Fix permissions for the key
    $USE_SUDO chmod a+r /etc/apt/keyrings/docker.asc
    # Add Docker repository for AWS
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | $USE_SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null
else
    echo "Running QEMU/Hypervisor-specific Docker installation..."
    # Create keyring directory with proper permissions
    install -m 0755 -d /etc/apt/keyrings
    # Download Docker GPG key for QEMU/Hypervisors
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    # Add Docker repository for QEMU/Hypervisors
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
fi
# Update package lists again
$USE_SUDO apt-get update
# Install Docker and dependencies
$USE_SUDO apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
echo "Docker installation complete!"