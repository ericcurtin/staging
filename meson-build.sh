#!/bin/bash

set -e

host="$1"

base="$(basename $PWD)"
path="/home/ecurtin/git/$base/"
cmd="meson build --prefix=/usr && ninja -v -C build && sudo ninja -v -C build install"

if [ -z "$host" ]; then
  /bin/bash -c "$cmd"
else
  clean="&& rm -rf build"
  if [ -z "$2" ]; then
    unset clean
  fi
  ssh $host "cd $path $clean && $cmd"
fi

