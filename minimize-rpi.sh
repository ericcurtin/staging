#!/bin/bash

for i in $(ssh guest@10.42.0.220 "ls /usr/lib/dracut/modules.d/"); do
  if [ "$i" == "00systemd" ] || [ "$i" == "01systemd-initrd" ] || [ "$i" == "05nss-softokn" ]; then
    echo "skipping '$i'"
    continue
  fi

  echo "boot-time, sizeof before removal and removing $i"
  ssh guest@10.42.0.220 "sudo systemd-analyze && sudo du -sh /boot/initramfs* && sudo mv /usr/lib/dracut/modules.d/$i /root/modules.d/ && sudo dracut -f && sudo reboot"
  echo "rebooting and sleeping for 64 seconds"
  echo
  sleep 64
done

