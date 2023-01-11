#!/bin/bash

set -ex

un=$(id -un)

cd ~/git/sample-images/osbuild-manifests/
EPOCH=$(date +%s)
../../staging/build-aboot-ostree.sh > ~/build-aboot-ostree$EPOCH.txt 2>&1

# type_img="qemu-minimal-ostree"
# type_img="abootqemu-minimal-ostree"
# type_img="abootqemu-minimal-regular"
uname_m=$(uname -m)

for type_img in abootqemu-minimal-ostree abootqemu-minimal-regular qemu-minimal-ostree qemu-minimal-regular; do
#for type_img in abootqemu-minimal-ostree; do
img="cs9-$type_img.$uname_m.qcow2"

# sudo make cs9-abootqemu-minimal-ostree.aarch64.qcow2 > ~/abootqemu-ostree$EPOCH.txt 2>&1
# sudo make $img DEFINES='extra_repos=[{"id":"extra","baseurl":"file:///home/ecurtin/rpmbuild/RPMS/"}]' > ~/$type_img$EPOCH.txt 2>&1
/bin/bash -c "sudo make $img > ~/$type_img$EPOCH.txt 2>&1" &
done

wait

sudo chown $un:$un cs9-*.qcow2

