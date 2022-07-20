#!/bin/bash

set -e

host="192.168.1.136"
echo "initial boot time"
ssh guest@$host "sudo systemd-analyze && sudo du -sh /boot/initramfs* && sudo reboot" || true
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
  if [ "$i" == "90kernel-modules" ]; then
    tested="false"
  fi

  if [ "$i" == "00systemd" ] || [ "$i" == "01systemd-initrd" ] || [ "$i" == "05nss-softokn" ] || [ "$i" == "90dmraid" ] || [ "$i" == "90kernel-modules" ]; then
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

