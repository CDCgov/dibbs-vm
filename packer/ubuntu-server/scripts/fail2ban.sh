#!/bin/bash

# This script configures and activates fail2ban on the configured VM.
# 1. Update package lists and install fail2ban.
# 2. Copies the provided jail.local file to the fail2ban configuration directory.
# 3. Enables the fail2ban service to start on boot.
# 4. Starts the fail2ban service for the first time.
# 5. Checks the status of the fail2ban service to ensure it is running. Outputs the 
#    status to the console for debugging purposes.
# Install fail2ban
sudo apt-get update && sudo apt-get install fail2ban -y
sudo cp ~/jail.local /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
sudo systemctl status fail2ban