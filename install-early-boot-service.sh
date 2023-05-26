#!/bin/bash

echo "[Unit]
Description=Early Boot Service
DefaultDependencies=no
Before=sysinit.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cat /proc/uptime" > /usr/lib/systemd/system/early-boot-service.service

/sbin/restorecon -v /usr/lib/systemd/system/early-boot-service.service
cd /usr/lib/systemd/system/sysinit.target.wants/
ln -s ../early-boot-service.service

mkdir -p /usr/lib/dracut/modules.d/00early-boot-service
echo '#!/usr/bin/bash

install() {
    inst_multiple -o \
      "$systemdsystemunitdir"/early-boot-service.service \
      "$systemdsystemunitdir"/sysinit.target.wants/early-boot-service.service
}' > /usr/lib/dracut/modules.d/00early-boot-service/module-setup.sh

dracut -f
rm -f /usr/lib/systemd/system/sysinit.target.wants/early-boot-service.service
aboot-update 5.14.0-999.124.pre.ES2.CCU.el9iv.aarch64
aboot-deploy -d /dev/vda1 aboot-5.14.0-999.124.pre.ES2.CCU.el9iv.aarch64.img
reboot

# journalctl --output=short-monotonic | grep -i "Starting Early"
# systemctl status early-boot-service

