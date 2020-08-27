#!/bin/bash

set -e

somewhere1="$PWD/../thesis/bin/openssl-quic"
somewhere2="$PWD/../thesis/bin/nghttp3"
somewhere3="$PWD/../thesis/bin/ngtcp2"

rm -rf $somewhere1
rm -rf $somewhere2
rm -rf $somewhere3
mkdir -p $somewhere1
mkdir -p $somewhere2
mkdir -p $somewhere3

nproc=$(nproc)

# Build openssl-quic

cd ..
if [ ! -d "$somewhere1" ]; then
  git clone -b OpenSSL_1_1_1d-quic-draft-27 https://github.com/tatsuhiro-t/openssl $somewhere1
fi

cd openssl-quic
git clean -fdx
git fetch
git reset --hard origin/OpenSSL_1_1_1d-quic-draft-27
./config enable-tls1_3 --prefix=$somewhere1
make -j$nproc
make install_sw

# Build nghttp3

cd ..
if [ ! -d "$somewhere2" ]; then
  git clone https://github.com/ngtcp2/nghttp3
fi

cd nghttp3
git clean -fdx
git fetch
git reset --hard origin/master
autoreconf -i
./configure --prefix=$somewhere2 --enable-lib-only
make -j$nproc
make install

# Build ngtcp2

cd ..
if [ ! -d "$somewhere3" ]; then
  git clone https://github.com/ngtcp2/ngtcp2
fi


cd ngtcp2
git clean -fdx
git fetch
git reset --hard origin/master
autoreconf -i
./configure PKG_CONFIG_PATH=$somewhere1/lib/pkgconfig:$somewhere2/lib/pkgconfig LDFLAGS="-Wl,-rpath,$somewhere1/lib" --prefix=$somewhere3
make -j$nproc
make install

# Build curl

cd ..
if [ ! -d "curl" ]; then
  git clone https://github.com/curl/curl
fi

cd curl
git clean -fdx
git fetch
git reset --hard origin/master
./buildconf
LDFLAGS="-Wl,-rpath,$somewhere1/lib" ./configure QUICHE=no --with-ssl=$somewhere1 --with-nghttp3=$somewhere2 --with-ngtcp2=$somewhere3 --enable-alt-svc
make -j$nproc

