#!/bin/bash

set -e

fn1="$1"
if [[ $fn1 == *.xz ]]; then
  cp $fn1 "to-unpack-$fn1"
  fn1="to-unpack-$fn1"
  xz -d -f "$fn1" &
  fn1="${fn1%.*}"
fi

fn2="$2"
if [[ $fn2 == *.xz ]]; then
  cp $fn2 "to-unpack-$fn2"
  fn2="to-unpack-$fn2"
  xz -d -f "$fn2" &
  fn2="${fn2%.*}"
fi

wait

unpack_bootimg --boot_img $fn1 --out out1 &
unpack_bootimg --boot_img $fn2 --out out2 &

wait

cd out1
fn1="$(mktemp)"
find . -type f -printf "%p %s\n" | sort > "$fn1" &
cd -

cd out2
fn2="$(mktemp)"
find . -type f -printf "%p %s\n" | sort > "$fn2" &
cd -

wait

diff "$fn1" "$fn2" || true

echo

file out1/kernel

echo

file out2/kernel

