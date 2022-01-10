#!/bin/bash

set -e

ssh -p 8022 127.0.0.1 "sudo init 0" || true
sleep 1
while pgrep -q qemu-system-aarch64; do
  sleep 1
done

sudo detach -e qemu.out -o qemu.out /Users/ecurtin/git/staging/qemu.sh
stopwatch &
stopwatch_pid=$!
tail -f qemu.out | grep -q -m1 'grub'
kill -HUP $stopwatch_pid
tail -f qemu.out | grep -q -m1 ^Kernel
kill $stopwatch_pid
echo

