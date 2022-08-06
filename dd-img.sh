#!/bin/bash

set -e

img=$1
dev=$2

if [ -z "$img" ]; then
  set +e
  ls *.iso *.img *.img.xz *.raw.xz 2> /dev/null
  set -e
  echo
  read -p "Image to write: " img
  echo
fi

if [ -z "$dev" ]; then
  sudo fdisk -l | grep -A2 "Disk /dev/m\|Disk /dev/s\|Disk /dev/l" | sed "s/://g"
  echo
  read -p "Disk to write to: " dev
  echo
  echo "Writing $img to $dev"
  echo
fi

# conv=fsync flushes caches at the end, just to be sure everything is written
# to disk
if [[ $img == *.raw.xz ]] || [[ $img == *.img.xz ]]; then
  xzcat $img | sudo dd of=$dev bs=4M status=progress conv=fsync
else
  sudo dd if=$img of=$dev bs=4M status=progress conv=fsync
fi

