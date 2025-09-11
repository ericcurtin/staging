#!/bin/bash

# podman machine init --disk-size 512 --memory 32768 --now --rootful --username $USER
podman machine start > /dev/null 2>&1
exec podman machine ssh --username $USER

