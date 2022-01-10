#!/bin/bash

set -e

# -device virtio-net-pci,netdev=net \
# -netdev user,id=net,ipv6=off \

dir="/var/root/fedora"
fw_opts="if=pflash,format=raw"

if ! command -v qemu-system-aarch64; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

uname_m=$(uname -m)
if [ $(echo $uname_m) = "arm64" ]; then
  # accel tcg
  /opt/homebrew/Cellar/qemu-virgl/20211212.1/bin/qemu-system-aarch64 \
    -machine virt,highmem=off -accel hvf \
    -cpu cortex-a72 -smp 8 -m 6G \
    -device intel-hda -device hda-output \
    -device qemu-xhci \
    -device virtio-gpu-gl-pci \
    -serial stdio \
    -device usb-kbd \
    -chardev socket,path=/tmp/port1,server=on,wait=off,id=port1-char \
    -device virtio-serial \
    -device virtserialport,id=port1,chardev=port1-char,name=org.fedoraproject.port.0 \
    -net user,hostfwd=tcp::8022-:22 -net nic \
    -device virtio-mouse-pci \
    -display cocoa,gl=es \
    -usb -device usb-ehci,id=ehci \
    -device usb-host,vendorid=0x046d,productid=0x0843 \
    -device qemu-xhci \
    -device usb-host,vendorid=0x0c76,productid=0x120c \
    -drive "if=pflash,format=raw,file=$dir/edk2-aarch64-code.fd,readonly=on" \
    -drive "if=pflash,format=raw,file=$dir/edk2-arm-vars.fd,discard=on" \
    -drive "if=virtio,format=raw,file=$dir/hdd.raw,discard=on"
elif [ $(echo $uname_m) = "x86_64" ]; then
  /usr/bin/qemu-system-x86_64 \
    -machine pc-q35-6.1,accel=kvm -cpu host -m 6G -smp 12 \
    -chardev socket,path=/tmp/port1,server=on,wait=off,id=port1-char \
    -device virtio-serial \
    -device virtserialport,id=port1,chardev=port1-char,name=org.fedoraproject.port.0 \
    -net user,hostfwd=tcp::8022-:22 \
    -drive if=virtio,file=/var/lib/libvirt/images/fedora35.qcow2,format=qcow2 \
    -usb -device usb-ehci,id=ehci -device usb-host,hostbus=1,hostaddr=2 \
    -net nic -display gtk

    # -usb -device usb-ehci,id=ehci -device usb-host,hostbus=1,hostaddr=2 for cam
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

