#!/bin/bash

set -e

echo "initial boot time"
ssh guest@10.42.0.220 "sudo systemd-analyze && sudo du -sh /boot/initramfs* && sudo reboot"
echo "rebooting and sleeping for 64 seconds"
echo
sleep 64

echo "initial boot time 2nd boot"
ssh guest@10.42.0.220 "sudo systemd-analyze && sudo du -sh /boot/initramfs* && sudo dracut -f && sudo reboot"
echo "rebooting and sleeping for 64 seconds"
echo
sleep 64

tested="true"

for i in $(ssh guest@10.42.0.220 "ls /usr/lib/dracut/modules.d/"); do
  if [ "$i" == "90dmraid" ]; then
    tested="false"
  fi

  if [ "$i" == "00systemd" ] || [ "$i" == "01systemd-initrd" ] || [ "$i" == "05nss-softokn" ] || [ "$i" == "90dmraid" ]; then
    echo "'$i' skip"
    echo
    continue
  fi

  if [ "$tested" == "false" ]; then
    dracut="&& sudo dracut -f && sudo reboot"
  fi

  echo "'$i' removal, boot-time, sizeof before removal"
  ssh guest@10.42.0.220 "sudo systemd-analyze && sudo du -sh /boot/initramfs* && sudo mv /usr/lib/dracut/modules.d/$i /root/modules.d/ $dracut"
  if [ "$tested" == "false" ]; then
    echo "rebooting and sleeping for 64 seconds"
    echo
    sleep 64
  fi
done

