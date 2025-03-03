#!/bin/bash

cd ../packer/ubuntu-server/ || exit

# check if the build directory exists
if [ -d "build/$1-$2" ]; then
    echo "Build directory for that version already exists."
    read -rp $'  \e[3m'"Do you want to remove the build directory? (y/n):"$'\e[0m' choice
    if [ "$choice" == "y" ]; then
        rm -rf "build/$1-$2"
    else
        echo "Cannot continue with the build process."
        exit 1
    fi
fi

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./build.sh [DIBBS_SERVICE] [DIBBS_VERSION]"
    echo "Example: ./build.sh dibbs-ecr-viewer 1.0.0"
    echo "Example: ./build.sh dibbs-query-connect 1.0.0"
    exit 1
fi

# init
packer init .

# validate
packer validate --var dibbs_service=$1 --var dibbs_version=$2 .

# Build the base image
packer build --var dibbs_service=$1 --var dibbs_version=$2 .

cd ../../utils/ || exit
