#!/bin/bash

set -ex

un=$(id -un)

cd ~/git/sample-images/osbuild-manifests/
EPOCH=$(date +%s)
../../staging/build-aboot-ostree.sh > ~/build-aboot-ostree$EPOCH.txt 2>&1

# type_img="qemu-minimal-ostree"
# type_img="abootqemu-minimal-ostree"
# type_img="abootqemu-minimal-regular"

for type_img in abootqemu-minimal-ostree abootqemu-minimal-regular; do
img="cs9-$type_img.aarch64.qcow2"

# sudo make cs9-abootqemu-minimal-ostree.aarch64.qcow2 > ~/abootqemu-ostree$EPOCH.txt 2>&1
sudo make $img > ~/$type_img$EPOCH.txt 2>&1
sudo chown $un:$un $img
done

