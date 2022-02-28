#!/bin/bash

set -e

# dnf -y install gcc flex make bison openssl openssl-devel elfutils-libelf-devel ncurses-devel bc git tar dwarves rpm-build
# cp /boot/config-<kernel-version>.aarch64 .config
j="$(nproc)"
make olddefconfig

if command -v ccache; then
  KBUILD_BUILD_TIMESTAMP='' make CC="ccache gcc" -j$j
else
  make -j$j
fi

make modules_install -j$j
make dtbs_install
make install
cd /boot
to_link="$(ls -t | grep dtb | grep -v ^dtb$ | head -n1)"
ln -sf $to_link dtb
to_grub="$(ls -t $PWD/vmlinuz-* | head -n1)"
grubby --set-default $to_grub

# mv /boot/dtbs/<new-version> /boot/dtb-<new-version>
# grubby --set-default /boot/<vmlinuz-new-version>
# sudo reboot

# On reboot, press esc to display menu and go to:
# Device manager -> Raspberry Pi Configuration -> Advanced Configuration
# Set < System Table Selection > to <ACPI + Devicetree> 

