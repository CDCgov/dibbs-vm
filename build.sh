#!/bin/bash

service=$1
version=$2
gitsha=$(git rev-parse --short HEAD)
build_type=${3:-"raw"} # raw, gcp, aws

cd packer/ubuntu-server/ || exit

echo "Build to be created: $build_type"

# check if the build directory exists
if [ -d "build/$service-$build_type-$version-$gitsha" ]; then
    echo "Build directory for that version already exists."
    read -rp $'  \e[3m'"Do you want to remove the build directory? (y/n): "$'\e[0m' choice
    if [ "$choice" == "y" ]; then
        rm -rf "build/$service-$build_type-$version-$gitsha"
    else
        echo "Cannot continue with the build process."
        exit 1
    fi
fi

if [ -z "$service" ] || [ -z "$version" ]; then
    echo "Usage: ./build.sh [DIBBS_SERVICE] [DIBBS_VERSION] [BUILD_TYPE (default: raw)]"
    echo "Example: ./build.sh dibbs-ecr-viewer 1.0.0"
    echo "Example: ./build.sh dibbs-query-connector 1.0.0 gcp"
    echo "Example: ./build.sh dibbs-ecr-viewer 1.0.0 aws"
    exit 1
fi

# build machines need to have OpenSSL installed for random password generation.
if ! command -v openssl &>/dev/null; then
    echo "openssl could not be found, exiting..."
    exit 1
fi

# generate a random password for the user
DIBBS_USER_PASSWORD=$(openssl rand -base64 24)
echo "Generated password: $DIBBS_USER_PASSWORD"

# generate the password hash for the user
password_hash=$(openssl passwd -6 $DIBBS_USER_PASSWORD)

# replace the password hash in the packer user-data file
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|'{{password_hash}}'|'"$password_hash"'|" ./http/user-data
else
    sed -i "s|'{{password_hash}}'|'"$password_hash"'|" ./http/user-data
fi
echo "Password replaced in user-data file."

# init
packer init .

# validate
packer validate --var dibbs_service="$service" --var dibbs_version="$version" --var ssh_password="$DIBBS_USER_PASSWORD" --var gitsha="$gitsha" --var build_type="$build_type" .

# Build the base image
packer build --var dibbs_service="$service" --var dibbs_version="$version" --var ssh_password="$DIBBS_USER_PASSWORD" --var gitsha="$gitsha" --var build_type="$build_type" .

echo "Remember, to login, you need to use the password: $DIBBS_USER_PASSWORD"

cd - || exit
