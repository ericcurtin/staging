mount -t proc proc /proc; mount -t sysfs sysfs /sys; mount -t devtmpfs devtmpfs /dev; /lib/systemd/systemd-udevd --daemon
time /bin/bash -c "udevadm trigger --type=devices --action=add --subsystem-match=module --subsystem-match=block --subsystem-match=virtio --subsystem-match=pci --subsystem-match=nvme; udevadm wait /dev/disk/by-uuid/76a22bf4-f153-4541-b6c7-0332c0dfaeac"
time /bin/bash -c "udevadm trigger --type=devices --action=add --subsystem-match=virtio /dev/disk/by-uuid/76a22bf4-f153-4541-b6c7-0332c0dfaeac; udevadm wait /dev/disk/by-uuid/76a22bf4-f153-4541-b6c7-0332c0dfaeac"

