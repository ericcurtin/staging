#!/bin/bash

if false; then
# Ensure a proper number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <image-name> <container-name> <volume-name>"
    exit 1
fi

IMAGE_NAME=$1
CONTAINER_NAME=$2
VOLUME_NAME=$3
fi

get_volume_dir() {
  podman volume inspect --format '{{ .Mountpoint }}' $1
}

set -e

IMAGE_NAME=$1

# Pull the Podman image
echo "Pulling image $IMAGE_NAME..."
podman pull "$IMAGE_NAME"
CONTAINER_NAME=$(podman create "$IMAGE_NAME")

VOLUME_NAME=$(basename "$IMAGE_NAME" | cut -d: -f1)
# Create a Podman volume
echo "Creating volume $VOLUME_NAME..."
podman volume rm -f "$VOLUME_NAME" || true
podman volume create "$VOLUME_NAME"

# Copy files from the container to the volume
echo "Copying files from container $CONTAINER_NAME to volume $VOLUME_NAME..."
volume_data_dir=$(get_volume_dir fedora)
podman cp "$CONTAINER_NAME":/ $volume_data_dir

# Remove the container
echo "Removing container $CONTAINER_NAME..."
podman rm "$CONTAINER_NAME"

# Remove the image
echo "Removing image $IMAGE_NAME..."
podman rmi "$IMAGE_NAME"

echo "Podman image converted to volume $VOLUME_NAME successfully!"

