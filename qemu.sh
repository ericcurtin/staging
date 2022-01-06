#!/bin/bash

set -e

# -device virtio-net-pci,netdev=net \
# -netdev user,id=net,ipv6=off \

qemu-system-aarch64 \
         -machine virt,accel=hvf,highmem=off \
         -cpu cortex-a72 -smp 8 -m 6G \
         -device intel-hda -device hda-output \
         -device qemu-xhci \
         -device virtio-gpu-gl-pci \
         -device usb-kbd \
         -device virtio-mouse-pci \
         -display cocoa,gl=es \
         -netdev vmnet-shared,id=n1 \
         -device virtio-net,netdev=n1 \
         -drive "if=pflash,format=raw,file=./edk2-aarch64-code.fd,readonly=on" \
         -drive "if=pflash,format=raw,file=./edk2-arm-vars.fd,discard=on" \
         -drive "if=virtio,format=raw,file=./hdd.raw,discard=on" \
         -boot d

