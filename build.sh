#!/bin/bash

set -ex

host="$1"
njobs=6
base="$(echo $PWD | sed "s#$HOME##g")"
path="~/$base/"
if [ -f "meson.build" ]; then
  # -Db_sanitize=address
  # --buildtype=debug
  # --buildtype=release
  cmd="meson build --buildtype=release --prefix=/usr && ninja -v -C build"
elif [ -f "SDL_image.h" ]; then
  extra="--disable-dependency-tracking --disable-jpg-shared \
         --disable-png-shared --disable-tif-shared --disable-webp-shared \
         --disable-static"
  cmd="if [ ! -f 'Makefile' ]; then ./autogen.sh && if [ -f 'configure' ]; then ./configure --prefix=/usr $extra; sed -i -e 's! -shared ! -Wl,--as-needed\0!g' libtool; fi; fi && make -j$njobs V=1 && sudo make install"
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

  extra2="&& sudo ln -s /usr/lib64/libSDL2-2.0.so.0 /usr/lib64/libSDL2.so"
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

  if [ -e "ggml" ]; then
    if false; then
      extra="-DBUILD_SHARED_LIBS=ON \
      -DGGML_KOMPUTE=ON"
    else
      extra="-DBUILD_SHARED_LIBS=ON \
      -DGGML_BLAS=ON \
      -DGGML_BLAS_VENDOR=Apple \
      -DGGML_METAL=ON \
      -DGGML_METAL_EMBED_LIBRARY=ON \
      -DGGML_NATIVE=ON \
      -DLLAMA_ALL_WARNINGS=OFF \
      -DLLAMA_CURL=ON"
    fi
  fi

  # -DCMAKE_BUILD_TYPE=Release
  # -DCMAKE_BUILD_TYPE=Debug this meses up the ln -s
  cmd="mkdir -p build && cd build && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_BUILD_TYPE=Debug $extra .. && make -j$njobs VERBOSE=1"
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

  # export CFLAGS="-fanalyzer"
  # export CXXFLAGS="-fanalyzer"
  # inotify-tools didn't like autogen.sh --prefix=/usr
  cmd="if [ ! -f 'Makefile' ]; then ./autogen.sh && if [ -f 'configure' ]; then ./configure --prefix=/usr $extra; fi; fi && make -j$njobs V=1"
elif [ -f "Cargo.lock" ]; then
  cmd="cargo install --path ."
elif [ -f "Cargo.lock" ]; then
  cmd="sudo go install ."
elif [ -f "Makefile" ] && [ -f "Kbuild" ] && [ -f "Kconfig" ]; then
  # sudo dnf install -y 'dnf-command(config-manager)'
  # sudo dnf config-manager --set-enabled crb
  # sudo dnf install -y epel-release
  # sudo dnf -y install ncurses-devel flex bison elfutils-libelf-devel dwarves ccache zstd bc rpm-build bpftool gcc perl-devel perl-generators python3-devel elfutils-devel the_silver_searcher openssl-devel openssl dracut linux-firmware binutils-devel gcc-plugin-devel glibc-static libcap-devel libcap-ng-devel libmnl-devel llvm nss-tools numactl-devel pesign python3-docutils libbpf-devel
  # sudo dnf -y install system-sb-certs
  if [ -e "/boot/dtb" ] || [ -e "/boot/dtbs" ]; then
    cmd="if [ ! -f '.config' ]; then cp /boot/config-\$(uname -r) .; fi && make olddefconfig && make -j$njobs && make -j$njobs modules && sudo make modules_install && sudo make dtbs_install INSTALL_DTBS_PATH=/boot/dtb-\$(make -s kernelrelease) && sudo make install"
#    to_link=$(for i in $(ls -t | grep dtb); do if [ -d "$i" ]; then echo $i; break; fi; done)
#    sudo ln -sf $to_link dtb
# make dist-srpm
# build locally: make dist-rpm-baseonly, all the rpms: make dist-rpms
# generate config: make dist-configs # just one cpu arch dist-configs-arch
  else
    cmd="if [ ! -f '.config' ]; then cp /boot/config-\$(uname -r) .; fi && make olddefconfig && make -j$njobs && make -j$njobs modules"
  fi
elif [ -f "Makefile" ]; then
  cmd="make -j$njobs"
elif [ -d "osbuild-manifests" ]; then
  cmd="cd osbuild-manifests; sudo make -j$njobs cs9-rpi4-developer-direct.aarch64.img"
elif [ -f "configure.ac" ]; then
  cmd="libtoolize --force && aclocal && autoheader && automake --force-missing --add-missing && autoconf && ./configure --prefix=/usr && make -j$njobs"
fi

# export CFLAGS="-O0 -ggdb"; export CXXFLAGS="$CFLAGS"; export LDFLAGS="$CFLAGS";
# export CFLAGS="$CFLAGS -fsanitize=address"; export CXXFLAGS="$CFLAGS"; export LDFLAGS="$CFLAGS"
# cmd="export CFLAGS='$CFLAGS'; export CXXFLAGS='$CFLAGS'; export LDFLAGS='$CFLAGS'; $cmd"
# cmd="if command -v ccache > /dev/null; then export CC='ccache gcc'; export CXX='ccache g++'; fi && $cmd"
# cmd="export CC='gcc'; export CXX='g++'; $cmd"
# cmd="export CC='clang'; export CXX='clang++'; $cmd"

if [ -z "$host" ]; then
  /bin/bash -c "$cmd"
else
  clean="&& rm -rf build && git clean -fdx"
  if [ -z "$2" ]; then
    unset clean
  fi

  ssh $host "cd $path $clean && $cmd"
fi

