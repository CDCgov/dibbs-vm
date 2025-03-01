#!/bin/bash

# Install Docker
echo "post-install"

# Ensure package lists are updated
sudo apt-get update -y

# Create keyring directory with proper permissions
sudo install -m 0755 -d /etc/apt/keyrings

# Download and store Docker's GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null

# Fix permissions for the key
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists again
sudo apt-get update -y

# Install Docker and dependencies
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin