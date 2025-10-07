#!/bin/bash

set -euo pipefail
set -x

service=$1
version=$2
bucket=$3
build_type=$4
gitsha=$(git rev-parse --short HEAD)

if [ -z "$service" ] || [ -z "$version" ]; then
  echo "Remember to log into gcloud before running this script."
  echo "Usage: ./aws_upload.sh [DIBBS_SERVICE] [DIBBS_VERSION]"
  echo "Example: ./aws_upload.sh dibbs-ecr-viewer 1.0.0 dibbs-vm-images"
  echo "Example: ./aws_upload.sh dibbs-query-connector 1.0.0 dibbs-vm-images"
  exit 1
fi

if [ -d "packer/ubuntu-server/build/$service-$build_type-$version-$gitsha/" ]; then
  cd packer/ubuntu-server/build/$service-$build_type-$version-$gitsha/ || exit
  echo "Build directory for that version exists, continuing with conversion."
else
  echo "Build directory for that version does not exist."
  exit 1
fi

rm disk.raw || true
rm ubuntu-2404-$service-$build_type-$version-$gitsha.tar.gz || true

# create raw
cp ubuntu-2404-$service-$build_type-$version-$gitsha.raw disk.raw

# compress raw
if [[ "$OSTYPE" == "darwin"* ]]; then
  gtar -czvf ubuntu-2404-$service-$build_type-$version-$gitsha.tar.gz disk.raw
else
  tar -czvf ubuntu-2404-$service-$build_type-$version-$gitsha.tar.gz disk.raw
fi

if [ $build_type == "aws" ]; then
  aws s3 cp ubuntu-2404-$service-$build_type-$version-$gitsha.tar.gz s3://$bucket
elif [ $build_type == "gcp" ]; then
  gsutil cp ubuntu-2404-$service-$build_type-$version-$gitsha.tar.gz gs://$bucket
else
  echo "Unknown build type: $build_type"
  exit 1
fi

cd - || exit
