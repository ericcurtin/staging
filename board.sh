#!/bin/bash

set -e

img_type="$1"

poweroff_fastboot() {
  /root/TAC_CCU/PowerOff.py
  /root/TAC_CCU/BootToFastBoot.py
  fastboot devices
}

docker_run() {
  docker run --rm -v $PWD:$PWD 01a11ffbacee /bin/bash -c "$1"
}

aboot() {
  poweroff_fastboot &
  pids_aboot+=($!)
  cp aboot.img.xz.$img_type aboot.img.xz
  unxz -f aboot.img.xz
  docker_run "cd /root/; abootimg -x aboot.img"
  sed -i "s/acpi=off console=ttyMSM0/acpi=off console=tty0 earlyprintk earlycon ignore_loglevel printk.devkmsg=on console=ttyMSM0/g" bootimg.cfg
  docker_run "cd /root/; abootimg -u aboot.img -f bootimg.cfg -k zImage -r initrd.img -d aboot.dtb"
  for pid in "${pids[@]}"; do
    wait -n
  done

  fastboot flash boot_a aboot.img
}

rootfs() {
  cp rootfs.simg.xz.$img_type rootfs.simg.xz
  unxz -f rootfs.simg.xz
}

[ -z "$img_type" ] && echo "Please pass one variable"

rm -rf zImage initrd.img aboot.dtb bootimg.cfg &
pids+=($!)
aboot &
pids+=($!)
rootfs &
pids+=($!)

for pid in "${pids[@]}"; do
  wait -n $pid
done

fastboot flash system_a rootfs.simg
/root/TAC_CCU/PowerOff.py
/root/TAC_CCU/PowerOn.py

