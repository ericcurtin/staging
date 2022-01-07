#!/bin/bash

set -e

mem="printf 'mem: '; awk '/MemTotal/ {printf int(\\\$2/1024)}' /proc/meminfo; echo M"

run() {
  j=$1
  cmd="cd ~/git/libcamera; rm -rf build; git reset --hard 44d59841e1ce59042b8069b8078bc9f7b1bfa73b; meson build -Dqcam=disabled; time ninja -C build -j$j; echo; grep -m1 'model name\|Hardware' /proc/cpuinfo; $mem; grep -m1 'cores' /proc/cpuinfo; printf 'jobs : $j\\n'"
#  ssh ecurtin@ecurtins-Mini.Home "ssh 192.168.64.2 \"$cmd\"" > m1.$j.bench 2>&1 &
  ssh ecurtin@ecurtins-Mini.Home "ssh -p 8022 127.0.0.1 \"$cmd\"" > m1.$j.bench 2>&1 &
  ssh root@192.168.1.102 "/bin/bash -c \"$cmd\"" > android.$j.bench 2>&1 &
  ssh ecurtin@pi "/bin/bash -c \"$cmd\"" > pi.$j.bench 2>&1 &
  /bin/bash -c "/bin/bash -c \"$cmd\"" > x86.$j.bench 2>&1 &
  wait
}

run 8
run 16

tail -n40 *.bench

