#!/bin/bash

# Check if DIBBS_SERVICE is valid
# dibbs-ecr-viewer
# dibbs-query-connect
if [ "$DIBBS_SERVICE" == "dibbs-ecr-viewer" ] || [ "$DIBBS_SERVICE" == "dibbs-query-connect" ]; then
  echo "DIBBS Service is valid. DIBBS_SERVICE=$DIBBS_SERVICE"
else
  echo "DIBBS Service is not valid. DIBBS_SERVICE=$DIBBS_SERVICE" && exit 1
fi

# Clone the dibbs-vm repository
git clone --branch alis/24 https://github.com/CDCgov/dibbs-vm.git

find ~/dibbs-vm.bak/docker/dibbs-ecr-viewer -name "*.env" | while read file; do
  cat "$file" > ~/dibbs-vm/docker/dibbs-ecr-viewer/"$(basename "$file")"
done

cp ~/dibbs-vm/packer/ubuntu-server/scripts/hot-upgrade.sh ~/hot-upgrade.sh

./wizard.sh
