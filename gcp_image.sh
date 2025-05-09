#!/bin/bash

set -euo pipefail
set -x

service=$1
version=$2
bucket=$3

if [ -z "$service" ] || [ -z "$version" ]; then
  echo "Remember to log into gcloud before running this script."
  echo "Usage: ./gcp_upload.sh [DIBBS_SERVICE] [DIBBS_VERSION]"
  echo "Example: ./gcp_upload.sh dibbs-ecr-viewer 1.0.0 dibbs-vm-bucket"
  echo "Example: ./gcp_upload.sh dibbs-query-connector 1.0.0 dibbs-vm-images"
  exit 1
fi

if [ -d "packer/ubuntu-server/build/$service-$version/" ]; then
  cd packer/ubuntu-server/build/$service-$version/ || exit
  echo "Build directory for that version exists, continuing with conversion."
else
  echo "Build directory for that version does not exist."
  exit 1
fi

rm disk.raw || true
rm ubuntu-2404-$service-$version.tar.gz || true

# create raw
cp ubuntu-2404-$service-$version.raw disk.raw

# compress raw
tar -czvf ubuntu-2404-$service-$version.tar.gz disk.raw

# upload to gcs
gsutil cp ubuntu-2404-$service-$version.tar.gz gs://$bucket

cd - || exit