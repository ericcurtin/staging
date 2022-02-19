#!/bin/bash

cp /boot/config-<kernel-version>.aarch64 .config
make olddefconfig
make -j$(nproc)
# make modules_install -j4
make dtbs_install
make install 
# mv /boot/dtbs/<new-version> /boot/dtb-<new-version>
# grubby --set-default /boot/<vmlinuz-new-version>
# sudo reboot

# On reboot, press esc to display menu and go to:
# Device manager -> Raspberry Pi Configuration -> Advanced Configuration
# Set < System Table Selection > to <ACPI + Devicetree> 

