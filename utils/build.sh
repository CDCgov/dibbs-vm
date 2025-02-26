#!/bin/bash

cd ../packer/ubuntu-server/ || exit

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./build.sh [DIBBS_SERVICE] [DIBBS_VERSION]"
    echo "Example: ./build.sh dibbs-ecr-viewer 1.0.0"
    echo "Example: ./build.sh dibbs-query-connect 1.0.0"
    exit 1
fi

# Build the base image
packer build --var dibbs_service=$1 --var dibbs_version=$2 ./ubuntu.pkr.hcl

cd ../../utils/ || exit