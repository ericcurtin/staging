#!/bin/bash

set -e

img=$1
dev=$2

if [ -z "$img" ]; then
  ls *.iso
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

sudo dd if=$img of=$dev bs=4M status=progress

