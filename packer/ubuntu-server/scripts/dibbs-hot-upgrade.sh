#!/bin/bash
# This script performs a hot upgrade for DIBBS services.
# It moves the existing dibbs-vm directory to a backup location,
# validates the DIBBS_SERVICE environment variable, clones the latest
# dibbs-vm repository, restores environment files, and runs the service wizard.

# Steps:
# 1. Move the existing dibbs-vm directory to a backup location.
# 2. Validate the DIBBS_SERVICE environment variable to ensure it is either
#    "dibbs-ecr-viewer" or "dibbs-query-connect". Exit if invalid.
# 3. Clone the dibbs-vm repository.
# 4. Restore environment files from the backup to the new repository.
# 5. Copy an updated version of this hotupdate script and wizard script.
# 6. Execute the service wizard script for the specified DIBBS service.

mv ~/dibbs-vm ~/dibbs-vm.bak

if [ "$DIBBS_SERVICE" == "dibbs-ecr-viewer" ] || [ "$DIBBS_SERVICE" == "dibbs-query-connect" ]; then
  echo "DIBBS Service is valid. DIBBS_SERVICE=$DIBBS_SERVICE"
else
  echo "DIBBS Service is not valid. DIBBS_SERVICE=$DIBBS_SERVICE" && exit 1
fi

# Clone the dibbs-vm repository
git clone --branch alis/24 https://github.com/CDCgov/dibbs-vm.git

find ~/dibbs-vm.bak/docker/"$DIBBS_SERVICE" -name "*.env" | while read file; do
  cat "$file" > ~/dibbs-vm/docker/"$DIBBS_SERVICE"/"$(basename "$file")"
done

cp ~/dibbs-vm/packer/ubuntu-server/scripts/dibbs-hot-upgrade.sh ~/dibbs-hot-upgrade.sh
cp ~/dibbs-vm/packer/ubuntu-server/scripts/"$DIBBS_SERVICE"-wizard.sh ~/"$DIBBS_SERVICE"-wizard.sh

./"$DIBBS_SERVICE"-wizard.sh
