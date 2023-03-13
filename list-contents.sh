#!/bin/bash

set -e

for type1 in ostree regular; do
some_dir="/home/ecurtin/git/sample-images/osbuild-manifests/abootqemu-minimal-$type1/cs9-abootqemu-minimal-$type1.aarch64.aboot"
# ls $some_dir/
qcow="/home/ecurtin/git/sample-images/osbuild-manifests/abootqemu-minimal-$type1/cs9-abootqemu-minimal-$type1.aarch64.qcow2"
sudo qemu-nbd --disconnect /dev/nbd0 > /dev/null
# sudo qemu-img resize $qcow 10G
sudo modprobe nbd max_part=10
sudo qemu-nbd --connect /dev/nbd0 $qcow
# sudo parted /dev/nbd0 resizepart 2 9G -s -f
# sudo fdisk /dev/nbd0 -l
for parti in "/dev/nbd0p2" "$some_dir/rootfs.img"; do
mkdir -p rootfs
sudo mount $parti rootfs
echo "Mounting $parti $type1:"
ls rootfs/
echo
sudo umount rootfs
done
# sudo dd if="$some_dir/aboot.img" of=/dev/nbd0p1 bs=4M status=progress conv=fsync
# sudo dd if="$some_dir/rootfs.img" of=/dev/nbd0p2 bs=4M status=progress conv=fsync
sudo qemu-nbd --disconnect /dev/nbd0 > /dev/null
done

