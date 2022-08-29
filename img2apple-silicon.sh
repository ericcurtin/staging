#!/bin/bash

set -ex

if [[ $1 == *.raw.xz ]] || [[ $1 == *.img.xz ]]; then
  file=$(basename $1)
  no_ext="${file%.*}"
  cp "$1" .
  unxz -f "$file"
  dev=$(sudo losetup --show -fP $no_ext)
  echo $dev
  p1=$(sudo fdisk -l $dev | grep p1 | awk '{print $1}')
  p2=$(sudo fdisk -l $dev | grep p2 | awk '{print $1}')
  p3=$(sudo fdisk -l $dev | grep p3 | awk '{print $1}')
  mkdir -p fake
  sudo mount $p3 fake
#  sudo mount $p2 fake/root/boot
#  sudo mount $p1 fake/root/boot/efi
  root="fake/root"
#  resolv="$root/etc/resolv.conf"
#  hosts="$root/etc/hosts"
  sudo cp $(which qemu-aarch64-static) $root/usr/bin
  sudo systemd-nspawn -D $root qemu-aarch64-static /bin/env -i TERM="$TERM" \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/bin /bin/bash -c "rm -f /etc/resolv.conf && \
    echo -e 'nameserver 8.8.8.8\nnameserver 8.8.4.4' > /etc/resolv.conf && \
    echo -e '127.0.0.1 localhost' > /etc/hosts && \
    dnf -y copr enable ecurtin/apple-sillicon && \
    dnf -y install asahi-fwextract asahi-scripts binutils efivar fedora-release grub2-efi-aa64-modules m1n1 m1n1-tools uboot-asahi update-m1n1 vim-enhanced NetworkManager-wifi" # additional asahi-fwextract asahi-scripts uboot-asahi update-m1n1
#  sudo umount fake/root/boot/efi
#  sudo umount fake/root/boot
  sudo umount fake 
  sudo losetup -D
  sudo sync &
else
  echo "Unrecognized extension in image filename: '$1'"
fi

