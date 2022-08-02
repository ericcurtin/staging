#!/bin/bash

set -e

# -device virtio-net-pci,netdev=net \
# -netdev user,id=net,ipv6=off \

dir="/var/root/fedora"
fw_opts="if=pflash,format=raw"

if ! command -v qemu-system-aarch64 > /dev/null; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

uname_m=$(uname -m)
if [ $(echo $uname_m) = "arm64" ]; then
  edk2_code=$(ls /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd | head -n1)
  edk2_vars=$(ls /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-arm-vars.fd | head -n1)
  
  # accel tcg
  qemu-system-aarch64 \
    -monitor stdio \
    -M virt,highmem=off \
    -accel hvf \
    -cpu host \
    -smp 8 \
    -m 3G \
    -device virtio-gpu-pci \
    -display default,show-cursor=on \
    -device qemu-xhci \
    -device usb-kbd \
    -device usb-tablet \
    -device intel-hda \
    -device hda-duplex \
    -net user,hostfwd=tcp::8022-:22 \
    -net nic \
    -drive "if=pflash,format=raw,file=$edk2_code,readonly=on" \
    -drive "if=pflash,format=raw,file=$edk2_vars,discard=on" \
    -drive "if=virtio,format=raw,file=/Users/ecurtin/fedora.raw,discard=on" 

# -usb -device usb-ehci,id=ehci -device usb-host,vendorid=0x0843,productid=0x046d \

#    -netdev vmnet-shared,id=net0 \
#    -device virtio-net,netdev=net0 \

#     -device qemu-xhci \
#    -device usb-host,vendorid=0x0c76,productid=0x120c \
# system_profiler SPUSBDataType
#        HP Webcam HD 4310:
#
#          Product ID: 0xe807
#          Vendor ID: 0x03f0  (Hewlett Packard)
#          Version: 11.16
#          Speed: Up to 480 Mb/s
#          Manufacturer: Hewlett Packard
#          Location ID: 0x02200000 / 24
#          Current Available (mA): 500
#          Current Required (mA): 500
#          Extra Operating Current (mA): 0
#
#        Logitech Webcam C930e:
#
#          Product ID: 0x0843
#          Vendor ID: 0x046d  (Logitech Inc.)
#          Version: 0.13
#          Serial Number: 7EFAD17E
#          Speed: Up to 480 Mb/s
#          Location ID: 0x02100000 / 22
#          Current Available (mA): 500
#          Current Required (mA): 500
#          Extra Operating Current (mA): 0
elif [ $(echo $uname_m) = "x86_64" ]; then
  /usr/bin/qemu-system-x86_64 \
    -machine pc-q35-6.1,accel=kvm -cpu host -m 14G -smp 12 \
    -drive if=virtio,file=hdd.raw,format=raw,discard=on \
    -vga virtio -display sdl,gl=es -usb -device usb-ehci,id=ehci \
    -net user,hostfwd=tcp::8022-:22 -net nic \
#    -cdrom ~/Downloads/Fedora-Workstation-Live-x86_64-36-1.5.iso \
#    -boot d
#-device usb-host,hostbus=1,hostaddr=2
#-vga [std|cirrus|vmware|qxl|xenfb|tcx|cg3|virtio|none]
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

