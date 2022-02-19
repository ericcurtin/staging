#!/bin/bash

set -e

host="$1"

base="$(basename $PWD)"
path="/home/ecurtin/git/$base/"
cmd="sudo bin/initrd-install.sh"

if [ -z "$host" ]; then
  /bin/bash -c "$cmd"
else
  clean="&& rm -rf build"
  if [ -z "$2" ]; then
    unset clean
  fi

  ssh $host "cd $path $clean && $cmd && sudo reboot"
fi

