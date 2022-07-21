#!/bin/bash

set -e

host="192.168.1.136"

ssh guest@$host "sudo dnf install -y git gcc g++ libevent libevent-devel \
  openssl openssl-devel gnutls gnutls-devel meson boost boost-devel python3-pip"

cd ../libcamera
git-push.sh guest@$host
cd -

cd ../twincam
git-push.sh guest@$host
cd -

ssh guest@$host 

echo "initial boot time"
ssh guest@$host "sudo mkdir -p /root/modules && sudo systemd-analyze && sudo du -sh /boot/initramfs* && sudo reboot" || true
echo "rebooting and sleeping for 64 seconds"
echo
sleep 64

echo "initial boot time 2nd boot"
ssh guest@$host "sudo systemd-analyze && sudo du -sh /boot/initramfs* && sudo dracut -f && sudo reboot" || true
echo "rebooting and sleeping for 64 seconds"
echo
sleep 64

tested="true"

for i in $(ssh guest@$host "ls /usr/lib/dracut/modules.d/"); do
#  if [ "$i" == "99fs-lib" ]; then
#    tested="false"
#  fi

  if [ "$i" == "00systemd" ] ||
     [ "$i" == "01systemd-initrd" ] ||
     [ "$i" == "05nss-softokn" ] ||
     [ "$i" == "90dmraid" ] ||
     [ "$i" == "90kernel-modules" ] ||
     [ "$i" == "95rootfs-block" ] ||
     [ "$i" == "95udev-rules" ] ||
     [ "$i" == "99base" ] ||
     [ "$i" == "99fs-lib" ]; then
    echo "skipping: '$i'"
    continue
  fi

  if [ "$tested" == "false" ]; then
    pre="sudo systemd-analyze && sudo du -sh /boot/initramfs* &&"
    post="&& sudo dracut -f && sudo reboot"
  fi

  echo "removing: '$i'"
  ssh guest@$host "$pre sudo mv /usr/lib/dracut/modules.d/$i /root/modules.d/ $post" || true
  if [ "$tested" == "false" ]; then
    echo "rebooting and sleeping for 64 seconds"
    echo
    sleep 64
  fi
done

tested="false"
pre="sudo systemd-analyze && sudo du -sh /boot/initramfs* &&"
post="&& sudo dracut -f && sudo reboot"
ssh guest@$host "$pre true $post" || true
if [ "$tested" == "false" ]; then
  echo "rebooting and sleeping for 64 seconds"
  echo
  sleep 64
fi

for i in $(ssh guest@$host "sudo lsinitrd -s | grep -i lib/modules | tac | awk '{print \$NF}' | grep -v ext4"); do
  if [ "$i" == "crc32c" ]; then
    echo "skipping: '$i'"
    continue
  fi

  echo "removing: '$i'"
  ssh guest@$host "$pre sudo mv /$i /root/modules/ $post" || true
  if [ "$tested" == "false" ]; then
    echo "rebooting and sleeping for 64 seconds"
    echo
    sleep 64
  fi
done

