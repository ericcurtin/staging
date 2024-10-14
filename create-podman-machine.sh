#!/bin/bash

set -e

# krunkit has an 8 cpu limit
podman machine init --cpus 8 --disk-size 256 -m 32768 --username ecurtin --now

