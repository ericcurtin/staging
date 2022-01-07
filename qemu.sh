#!/bin/bash

set -e

# -device virtio-net-pci,netdev=net \
# -netdev user,id=net,ipv6=off \

dir="/var/root/fedora"
fw_opts="if=pflash,format=raw"

if ! command -v qemu-system-aarch64; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if false; then # graphics version
/opt/homebrew/Cellar/qemu-virgl/20211212.1/bin/qemu-system-aarch64 \
         -machine virt,highmem=off \
         -accel hvf -accel tcg \
         -cpu cortex-a72 -smp 8 -m 6G \
         -device intel-hda -device hda-output \
         -device qemu-xhci \
         -device virtio-gpu-gl-pci \
         -device usb-kbd \
         -device virtio-mouse-pci \
         -display cocoa,gl=es \
         -netdev vmnet-shared,id=n1 \
         -device virtio-net,netdev=n1 \
         -drive "$fw_opts,file=$dir/edk2-aarch64-code.fd,readonly=on" \
         -drive "$fw_opts,file=$dir/edk2-arm-vars.fd,discard=on" \
         -drive "if=virtio,format=raw,file=$dir/hdd.raw,discard=on"
else
/opt/homebrew/bin/qemu-system-aarch64 \
         -m 6G -smp 8 \
         -chardev socket,path=/tmp/port1,server=on,wait=off,id=port1-char \
         -device virtio-serial \
         -device virtserialport,id=port1,chardev=port1-char,name=org.fedoraproject.port.0 \
         -net user,hostfwd=tcp::8022-:22 \
         -net nic \
         -accel hvf -accel tcg -cpu cortex-a57 \
         -M virt,highmem=off \
         -drive file=$dir/edk2-aarch64-code.fd,$fw_opts,readonly=on \
         -drive file=$dir/edk2-arm-vars.fd,$fw_opts \
         -drive if=virtio,file=$dir/hdd.raw,format=raw -display cocoa
fi

