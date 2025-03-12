#!/bin/bash

service=$1
version=$2
cd packer/ubuntu-server/ || exit

# check if the build directory exists
if [ -d "build/$service-$version" ]; then
    echo "Build directory for that version already exists."
    read -rp $'  \e[3m'"Do you want to remove the build directory? (y/n): "$'\e[0m' choice
    if [ "$choice" == "y" ]; then
        rm -rf "build/$service-$version"
    else
        echo "Cannot continue with the build process."
        exit 1
    fi
fi

if [ -z "$service" ] || [ -z "$version" ]; then
    echo "Usage: ./build.sh [DIBBS_SERVICE] [DIBBS_VERSION]"
    echo "Example: ./build.sh dibbs-ecr-viewer 1.0.0"
    echo "Example: ./build.sh dibbs-query-connector 1.0.0"
    exit 1
fi

# init
packer init .

# validate
packer validate --var dibbs_service="$service" --var dibbs_version="$version" .

# Build the base image
packer build --var dibbs_service="$service" --var dibbs_version="$version" .

cd ../../ || exit
