#!/bin/bash

set -ex

cd ~/git/sample-images/osbuild-manifests

EPOCH=$(date +%s)
IMG="cs9-abootqemu-minimal-ostree"
# IMG="cs9-abootqemu-minimal-regular"
nohup /bin/bash -c "../../staging/build-aboot-ostree.sh > ~/build-aboot-ostree$EPOCH.txt 2>&1 && sudo make $IMG.aarch64.qcow2 > ~/$IMG$EPOCH.txt 2>&1" &

