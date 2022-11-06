#!/bin/bash

set -ex

EPOCH=$(date +%s)
../../staging/build-aboot-ostree.sh > ~/build-aboot-ostree$EPOCH.txt 2>&1
sudo make cs9-abootqemu-minimal-ostree.aarch64.qcow2 > ~/abootqemu-ostree$EPOCH.txt 2>&1

