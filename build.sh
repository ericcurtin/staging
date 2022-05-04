#!/bin/bash

set -e

host="$1"

base="$(echo $PWD | sed "s#$HOME##g")"
path="~/$base/"
if [ -f "meson.build" ]; then
  # -Db_sanitize=address
  # --buildtype=debug
  # --buildtype=release
  cmd="meson build -Db_sanitize=address --buildtype=debug --prefix=/usr && ninja -v -C build && sudo ninja -v -C build install"
elif [ -f "CMakeLists.txt" ]; then # sdl prefer this over autogen.sh
  if [ -f "sdl2.m4" ]; then # sdl specific
    extra="-DSDL_DLOPEN=ON \
           -DSDL_VIDEO_KMSDRM=ON \
           -DSDL_ARTS=OFF \
           -DSDL_ESD=OFF \
           -DSDL_NAS=OFF \
           -DSDL_PULSEAUDIO_SHARED=ON \
           -DSDL_JACK_SHARED=ON \
           -DSDL_PIPEWIRE_SHARED=ON \
           -DSDL_ALSA=ON \
           -DSDL_VIDEO_WAYLAND=ON \
           -DSDL_LIBDECOR_SHARED=ON \
           -DSDL_VIDEO_VULKAN=ON \
           -DSDL_SSE3=OFF \
           -DSDL_RPATH=OFF \
           -DSDL_STATIC=ON \
           -DSDL_STATIC_PIC=ON"

    if false; then
    extra="-DSDL_DLOPEN=OFF \
    -DSDL_VIDEO_KMSDRM=ON \
    -DSDL_ARTS=OFF \
    -DSDL_ESD=OFF \
    -DSDL_NAS=OFF \
    -DSDL_PULSEAUDIO_SHARED=OFF \
    -DSDL_JACK_SHARED=OFF \
    -DSDL_PIPEWIRE_SHARED=OFF \
    -DSDL_ALSA=OFF \
    -DSDL_VIDEO_WAYLAND=ON \
    -DSDL_LIBDECOR_SHARED=OFF \
    -DSDL_VIDEO_VULKAN=OFF \
    -DSDL_SSE3=OFF \
    -DSDL_RPATH=OFF \
    -DSDL_STATIC=OFF \
    -DSDL_STATIC_PIC=OFF \
    -DSDL_ALTIVEC=OFF"
fi
  fi

  # -DCMAKE_BUILD_TYPE=Release
  # -DCMAKE_BUILD_TYPE=Debug
  cmd="mkdir -p build && cd build && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_BUILD_TYPE=Release $extra .. && make -j\$(nproc) VERBOSE=1 && sudo make install"
elif [ -f "autogen.sh" ]; then
  if grep -q plymouth README; then
    extra="--enable-tracing                                      \
           --with-logo=/usr/share/pixmaps/system-logo-white.png  \
           --with-background-start-color-stop=0x0073B3           \
           --with-background-end-color-stop=0x00457E             \
           --with-background-color=0x3391cd                      \
           --with-runtimedir=/run                                \
           --disable-gdm-transition                              \
           --enable-systemd-integration                          \
           --without-system-root-install                         \
           --without-rhgb-compat-link"
  fi

  # inotify-tools didn't like autogen.sh --prefix=/usr
  cmd="if [ ! -f 'Makefile' ]; then ./autogen.sh && if [ -f 'configure' ]; then ./configure --prefix=/usr $extra; fi; fi && make -j\$(nproc) V=1 && sudo make install"
elif [ -f "Cargo.lock" ]; then
  cmd="sudo cargo install --path ."
elif [ -f "Cargo.lock" ]; then
  cmd="sudo go install ."
elif [ -f "Makefile" ] && [ -f "Kbuild" ] && [ -f "Kconfig" ]; then # linux kern
  cmd="if [ ! -f '.config' ]; then cp /boot/config-\$(uname -r) .; fi && make olddefconfig && make -j\$(nproc)"
elif [ -f "Makefile" ]; then
  cmd="make -j\$(nproc)"
elif [ -d "osbuild-manifests" ]; then
  cmd="cd osbuild-manifests; sudo make -j\$(nproc) cs9-rpi4-developer-direct.aarch64.img"
fi

# export CFLAGS="-O1 -ggdb"; export CXXFLAGS="$CFLAGS"; export LDFLAGS="$CFLAGS";
# export CFLAGS="$CFLAGS -fsanitize=address"; export CXXFLAGS="$CFLAGS"; export LDFLAGS="$CFLAGS"
# cmd="export CFLAGS='$CFLAGS'; export CXXFLAGS='$CFLAGS'; export LDFLAGS='$CFLAGS'; $cmd"
cmd="if command -v ccache > /dev/null; then export CC='ccache gcc'; export CXX='ccache g++'; fi && $cmd"

if [ -z "$host" ]; then
  /bin/bash -c "$cmd"
else
  clean="&& rm -rf build && git clean -fdx"
  if [ -z "$2" ]; then
    unset clean
  fi

  ssh $host "cd $path $clean && $cmd"
fi

