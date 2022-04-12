#!/bin/bash

set -e

host="$1"

if [ -z "$host" ]; then
  sudo cam -c1 -S -C0 --stream pixelformat=YUYV
else
  ssh $host "sudo cam -c1 -S -C0 --stream pixelformat=YUYV"
fi

