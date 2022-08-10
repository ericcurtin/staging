#!/bin/bash

set -ex

img=$1

if ! command -v gparted; then
  echo "Please install gparted"
  exit 1
fi

if [ -z "$img" ]; then
  set +e
  ls *.qcow2 *.qcow2.xz 2> /dev/null
  set -e
  echo
  read -p "Image to write: " img
  echo
fi

read -p "Total size (eg. 250G): " size

img_wo_ext=${img%.*}
unxz $img
qemu-img info $img_wo_ext | grep "virtual size"
qemu-img resize $img_wo_ext $size
sudo modprobe nbd max_part=10
sudo qemu-nbd -c /dev/nbd0 $img_wo_ext
sudo gparted /dev/nbd0

