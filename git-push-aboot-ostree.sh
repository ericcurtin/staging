#!/bin/bash

set -e

for i in aboot-update autosig-qemu-dtb ostree aboot-deploy osbuild-aboot sample-images staging; do
  cd ~/git/$i
  git-push.sh $1 &
done

wait

