#!/bin/bash

set -euo pipefail
set -x

service=$1
version=$2
bucket=${3:-"skylight-dibbs-vm-images"}
# accept an argument or use the default to "gcp raw"
build_types=(gcp raw)
gitsha=$(git rev-parse --short HEAD)

if [ -z "$service" ] || [ -z "$version" ]; then
  echo "Remember to log into gcloud before running this script."
  echo "Usage: ./gcp_upload.sh [DIBBS_SERVICE] [DIBBS_VERSION] [BUCKET_NAME]"
  echo "Example: ./gcp_upload.sh dibbs-ecr-viewer 1.0.0 skylight-dibbs-vm-images"
  echo "Example: ./gcp_upload.sh dibbs-query-connector 1.0.0 skylight-dibbs-vm-images"
exit 1
fi

# Create a loop for gcp and raw
for build_type in "${build_types[@]}"; do
  if [ -d "packer/ubuntu-server/build/$service-$build_type-$version-$gitsha" ]; then
    cd packer/ubuntu-server/build/$service-$build_type-$version-$gitsha || exit
    echo "Build directory for that version exists, continuing with conversion."
  else
    echo "Build directory for that version does not exist."
    exit 1
  fi
  gsutil ls gs://$bucket/ubuntu-2404-$service-$build_type-$version-$gitsha.tar.gz && {
    echo "File already exists in the bucket. Exiting to avoid overwrite."
    exit 1
  } || {
    echo "File does not exist in the bucket. Continuing with upload."
  }

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

  # upload to gcs
  gsutil cp ubuntu-2404-$service-$build_type-$version-$gitsha.tar.gz gs://$bucket

  cd - || exit
done