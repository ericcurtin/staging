#!/bin/bash

# podman machine init --disk-size 256 --memory 16384 --now --rootful --username $USER
podman machine start > /dev/null 2>&1
exec podman machine ssh

