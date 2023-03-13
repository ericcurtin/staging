#!/bin/bash

set -ex

cd

type1="ostree"
some_dir="/home/ecurtin/git/sample-images1/osbuild-manifests/abootqemu-minimal-$type1/cs9-abootqemu-minimal-$type1.aarch64.aboot"
ls -ltr $some_dir/
qcow="/home/ecurtin/git/sample-images/osbuild-manifests/abootqemu-minimal-ostree/cs9-abootqemu-minimal-ostree.aarch64.qcow2"
#qcow="/home/ecurtin/git/sample-images/osbuild-manifests/cs9-abootqemu-developer-ostree.aarch64.qcow2"
sudo qemu-nbd --disconnect /dev/nbd0 || true
sudo qemu-img resize $qcow 10G
sudo modprobe nbd max_part=10
sudo qemu-nbd --connect /dev/nbd0 $qcow
sudo parted /dev/nbd0 resizepart 2 9G -s -f
sudo fdisk /dev/nbd0 -l
sudo dd if="$some_dir/aboot.img" of=/dev/nbd0p1 bs=4M status=progress conv=fsync
sudo dd if="$some_dir/rootfs.img" of=/dev/nbd0p2 bs=4M status=progress conv=fsync
sudo qemu-nbd --disconnect /dev/nbd0

