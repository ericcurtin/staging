#!/bin/bash

set -e

dnf install -y epel-release
dnf install -y gcc-c++-aarch64-linux-gnu xz
cd /usr/aarch64-linux-gnu/
curl -OL https://cloud.centos.org/centos/9-stream/aarch64/images/CentOS-Stream-Container-Base-9-20220919.0.aarch64.tar.xz
cd sys-root
tar -xOf ../CentOS-Stream-Container-Base-9-20220919.0.aarch64.tar.xz --wildcards --no-anchored 'layer.tar' | tar xf -
dnf install -y --forcearch=aarch64 --installroot=$PWD --releasever=9 gcc-toolset-12-libstdc++-devel glibc-headers
echo -e "#include <iostream>\n int main() { std::cout << \"Some dynamically linked cross-compiled C++ application\\\n\"; return 0; }" > a.cpp
mkdir -p /usr/lib/gcc/aarch64-linux-gnu/12/../../../../aarch64-linux-gnu/include/
cp -r opt/rh/gcc-toolset-12/root/usr/include/c++ /usr/lib/gcc/aarch64-linux-gnu/12/../../../../aarch64-linux-gnu/include/
mv /usr/lib/gcc/aarch64-linux-gnu/12/../../../../aarch64-linux-gnu/include/c++/12/aarch64-redhat-linux /usr/lib/gcc/aarch64-linux-gnu/12/../../../../aarch64-linux-gnu/include/c++/12/aarch64-linux-gnu
cp opt/rh/gcc-toolset-12/root/usr/lib/gcc/aarch64-redhat-linux/12/* usr/lib64/
aarch64-linux-gnu-g++ a.cpp

