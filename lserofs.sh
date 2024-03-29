#!/bin/bash

img=$1

dev=$(sudo losetup --show -fP $img)
dir=$(mktemp -d)
sudo mount $dev $dir
find $dir | sed "s#^$dir##g"
sudo umount $dir
sudo losetup -d $dev
rm -rf $dir

