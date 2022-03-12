#!/bin/bash

set -e

host="$1"

base="$(basename $PWD)"
path="~/git/$base/"
if [ -f "meson.build" ]; then
  cmd="meson build --prefix=/usr && ninja -v -C build && sudo ninja -v -C build install"
elif [ -f "autogen.sh" ]; then
  cmd="./autogen.sh --prefix=/usr && make -j\$(nproc) && sudo make install"
elif [ -f "CMakeLists.txt" ]; then
  cmd="mkdir -p build && cd build && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_BUILD_TYPE=Release .. && make -j\$(nproc) VERBOSE=1 && sudo make install"
elif [ -f "Cargo.lock" ]; then
  cmd="sudo cargo install --path ."
elif [ -f "Makefile" ] && [ -f "Kbuild" ] && [ -f "Kconfig" ]; then # linux kern
  cmd="if [ ! -f '.config' ]; then cp /boot/config-\$(uname -r) .; fi && make olddefconfig && make -j\$(nproc)"
fi

if [ -z "$host" ]; then
  /bin/bash -c "$cmd"
else
  clean="&& rm -rf build"
  if [ -z "$2" ]; then
    unset clean
  fi

  ssh $host "cd $path $clean && $cmd"
fi

