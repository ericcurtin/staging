#!/bin/bash

set -ex

host="192.168.1.136"

ssh guest@$host "sudo dnf install -y 'dnf-command(config-manager)'"
ssh guest@$host "sudo dnf config-manager --set-enabled crb"
ssh guest@$host "sudo dnf install -y epel-release"
ssh guest@$host "sudo dnf install -y git gcc g++ libevent libevent-devel \
  openssl openssl-devel gnutls gnutls-devel meson boost boost-devel \
  python3-pip systemd-udev doxygen cmake graphviz libatomic texlive-latex"
ssh guest@$host "sudo dnf remove -y rsyslog"
ssh guest@$host "sudo pip install jinja2 ply pyyaml"

cd ../libcamera
git-push.sh guest@$host
cd -

cd ../twincam
git-push.sh guest@$host
cd -

ssh guest@$host "cd git/libcamera && meson build --prefix=/usr && ninja -v -C build && sudo ninja -v -C build install"
perf="sudo systemd-analyze && sudo du -sh /boot/initramfs* &&"
ssh guest@$host "cd git/twincam && meson build --prefix=/usr && ninja -v -C build && sudo ninja -v -C build install && $perf sudo ./install-minimal.sh"

s="61"
echo "initial boot time"
ssh guest@$host "sudo mkdir -p /root/modules && $perf sudo reboot" || true
echo "rebooting and sleeping for $s seconds"
echo
sleep $s

perf="sudo journalctl -r | grep 'seq: 0' | head -n1 && $perf"
echo "initial boot time 2nd boot"
ssh guest@$host "$perf sudo dracut -f && sudo reboot" || true
echo "rebooting and sleeping for $s seconds"
echo
sleep $s

tested="true"

for i in $(ssh guest@$host "ls /usr/lib/dracut/modules.d/"); do
#  if [ "$i" == "99fs-lib" ]; then
#    tested="false"
#  fi

  if [ "$i" == "00systemd" ] ||
     [ "$i" == "01systemd-initrd" ] ||
     [ "$i" == "05nss-softokn" ] ||
     [ "$i" == "81twincam" ] ||
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
    pre="$perf"
    post="&& sudo dracut -f && sudo reboot"
  fi

  echo "removing: '$i'"
  ssh guest@$host "$pre sudo mv /usr/lib/dracut/modules.d/$i /root/modules.d/ $post" || true
  if [ "$tested" == "false" ]; then
    echo "rebooting and sleeping for $s seconds"
    echo
    sleep $s
  fi
done

tested="false"
pre="$perf"
post="&& sudo dracut -f && sudo reboot"
ssh guest@$host "$pre true $post" || true
if [ "$tested" == "false" ]; then
  echo "rebooting and sleeping for $s seconds"
  echo
  sleep $s
fi

tested="true"
pre=""
post=""

for i in $(ssh guest@$host "sudo lsinitrd -s | grep -i lib/modules | tac | awk '{print \$NF}' | grep -v ext4"); do
  if [[ "$i" == */cifs_arc4.ko.xz ]]; then
    tested="false"
  fi

  # awk -F= '{print $3}' | awk '{print $1}' | awk -F/ '{print "     [[ $i == */"$NF" ]] ||"}' | sort | uniq
  if [[ $i == */modules.alias.bin ]] ||
     [[ $i == */qed.ko.xz ]] ||
     [[ $i == */cxgb4.ko.xz ]] ||
     [[ $i == */sunrpc.ko.xz ]] ||
     [[ $i == */libceph.ko.xz ]] ||
     [[ $i == */target_core_mod.ko.xz ]] ||
     [[ $i == */zstd_compress.ko.xz ]] ||
     [[ $i == */videode*.ko.xz ]] ||
     [[ $i == */modules.dep.bin ]] ||
     [[ $i == */libnvdimm.ko.xz ]] ||
     [[ $i == */qedf.ko.xz ]] ||
     [[ $i == */ufshcd-core.ko.xz ]] ||
     [[ $i == */dm-mod.ko.xz ]] ||
     [[ $i == */fuse.ko.xz ]] ||
     [[ $i == */modules.builtin ]] ||
     [[ $i == */modules.order ]] ||
     [[ $i == */modules.dep ]] ||
     [[ $i == */modules.builtin.modinfo ]] ||
     [[ $i == */modules.alias.bin ]] ||
     [[ $i == */modules.alias ]] |
     [[ $i == */raid6_pq.ko.xz ]] ||
     [[ $i == */mmc_core.ko.xz ]] ||
     [[ $i == */libfc.ko.xz ]] ||
     [[ $i == */uvcvideo.ko.xz ]] ||
     [[ $i == */nvme-core.ko.xz ]] ||
     [[ $i == */scsi_transport_iscsi.ko.xz ]] ||
     [[ $i == */jbd2.ko.xz ]] ||
     [[ $i == */tls.ko.xz ]] ||
     [[ $i == */overlay.ko.xz ]] ||
     [[ $i == */snd.ko.xz ]] ||
     [[ $i == */rmi_core.ko.xz ]] ||
     [[ $i == */hv_vmbus.ko.xz ]] ||
     [[ $i == */libsas.ko.xz ]] ||
     [[ $i == */nvmet.ko.xz ]] ||
     [[ $i == */libiscsi.ko.xz ]] ||
     [[ $i == */hv_vmbus.ko.xz ]] ||
     [[ $i == */mptbase.ko.xz ]] ||
     [[ $i == */fscache.ko.xz ]] ||
     [[ $i == */fat.ko.xz ]] ||
     [[ $i == */usb-storage.ko.xz ]] ||
     [[ $i == */mtd.ko.xz ]] ||
     [[ $i == */nvme-fc.ko.xz ]] ||
     [[ $i == */libfcoe.ko.xz ]] ||
     [[ $i == */ccp.ko.xz ]] ||
     [[ $i == */sdhci.ko.xz ]] ||
     [[ $i == */cec.ko.xz ]] ||
     [[ $i == */videobuf2-common.ko.xz ]] ||
     [[ $i == */gspca_main.ko.xz ]] ||
     [[ $i == */hisi_sas_main.ko.xz ]] ||
     [[ $i == */qmi_helpers.ko.xz ]] ||
     [[ $i == */scsi_transport_fc.ko.xz ]] ||
     [[ $i == */cdrom.ko.xz ]] ||
     [[ $i == */nvme.ko.xz ]] ||
     [[ $i == */mc.ko.xz ]] ||
     [[ $i == */dw_mmc.ko.xz ]] ||
     [[ $i == */nvmet-fc.ko.xz ]] ||
     [[ $i == */error.ko.xz ]] ||
     [[ $i == */mptscsih.ko.xz ]] ||
     [[ $i == */phy-tegra-xusb.ko.xz ]] ||
     [[ $i == */ci_hdrc.ko.xz ]] ||
     [[ $i == */udc-core.ko.xz ]] ||
     [[ $i == */videobuf2-v4l2.ko.xz ]] ||
     [[ $i == */snd-rawmidi.ko.xz ]] ||
     [[ $i == */sg.ko.xz ]] ||
     [[ $i == */netfs.ko.xz ]] ||
     [[ $i == */trusted.ko.xz ]] ||
     [[ $i == */pmbus_core.ko.xz ]] ||
     [[ $i == */tee.ko.xz ]] ||
     [[ $i == */dw_dmac_core.ko.xz ]] ||
     [[ $i == */hdma.ko.xz ]] ||
     [[ $i == */nd_btt.ko.xz ]] ||
     [[ $i == */qcom_glink.ko.xz ]] ||
     [[ $i == */qcom_rpmh.ko.xz ]] ||
     [[ $i == */qcom_smd.ko.xz ]] ||
     [[ $i == */scsi_transport_sas.ko.xz ]] ||
     [[ $i == */nvme-fabrics.ko.xz ]] ||
     [[ $i == */videobuf-core.ko.xz ]] ||
     [[ $i == */spmi.ko.xz ]] ||
     [[ $i == */i2c-hid.ko.xz ]] ||
     [[ $i == */twofish_common.ko.xz ]] ||
     [[ $i == */vdpa.ko.xz ]] ||
     [[ $i == */v4l2-dv-timings.ko.xz ]] ||
     [[ $i == */i2c-designware-core.ko.xz ]] ||
     [[ $i == */vfat.ko.xz ]] ||
     [[ $i == */pci-hyperv.ko.xz ]] ||
     [[ $i == */sr_mod.ko.xz ]] ||
     [[ $i == */arm_scpi.ko.xz ]] ||
     [[ $i == */virtio_blk.ko.xz ]] ||
     [[ $i == */virtio_scsi.ko.xz ]] ||
     [[ $i == */mtd_blkdevs.ko.xz ]] ||
     [[ $i == */uas.ko.xz ]] ||
     [[ $i == */sha256-arm64.ko.xz ]] ||
     [[ $i == */ff-memless.ko.xz ]] ||
     [[ $i == */rpmsg_core.ko.xz ]] ||
     [[ $i == */smem.ko.xz ]] ||
     [[ $i == */phy-generic.ko.xz ]] ||
     [[ $i == */memstick.ko.xz ]] ||
     [[ $i == */smem.ko.xz ]] ||
     [[ $i == */rpmsg_core.ko.xz ]] ||
     [[ $i == */reed_solomon.ko.xz ]] ||
     [[ $i == */libahci_platform.ko.xz ]] ||
     [[ $i == */blowfish_common.ko.xz ]] ||
     [[ $i == */libdes.ko.xz ]] ||
     [[ $i == */qcom-geni-se.ko.xz ]] ||
     [[ $i == */mbcache.ko.xz ]] ||
     [[ $i == */ehci-platform.ko.xz ]] ||
     [[ $i == */tifm_core.ko.xz ]] ||
     [[ $i == */videobuf2*.ko.xz ]] ||
     [[ $i == */raspberrypi.ko.xz ]] ||
     [[ $i == */dns_resolver.ko.xz ]] ||
     [[ $i == */cast_common.ko.xz ]] ||
     [[ $i == */async_raid6_recov.ko.xz ]] ||
     [[ $i == */async_pq.ko.xz ]] ||
     [[ $i == */async_xor.ko.xz ]] ||
     [[ $i == */gpio-generic.ko.xz ]] ||
     [[ $i == */hid-roccat.ko.xz ]] ||
     [[ $i == */i2c-algo-bit.ko.xz ]] ||
     [[ $i == */i2c-algo-pca.ko.xz ]] ||
     [[ $i == */iscsi_boot_sysfs.ko.xz ]] ||
     [[ $i == */asn1_encoder.ko.xz ]] ||
     [[ $i == */async_memcpy.ko.xz ]] ||
     [[ $i == */cmd-db.ko.xz ]] ||
     [[ $i == */ecdh_generic.ko.xz ]] ||
     [[ $i == */ezusb.ko.xz ]] ||
     [[ $i == */grace.ko.xz ]] ||
     [[ $i == */libcrc32c.ko.xz ]] ||
     [[ $i == */mdt_loader.ko.xz ]] ||
     [[ $i == */nfs_acl.ko.xz ]] ||
     [[ $i == */ulpi.ko.xz ]] ||
     [[ $i == */xxhash_generic.ko.xz ]] ||
     [[ $i == */sha2-ce.ko.xz ]] ||
     [[ $i == *raspberryp*.ko.xz ]] ||
     [[ $i == *bcm*.ko.xz ]] ||
     [[ $i == *qcom*.ko.xz ]] ||
     [[ $i == */asn1_encoder.ko.xz ]] ||
     [[ $i == */async_tx.ko.xz ]] ||
     [[ $i == */auth_rpcgss.ko.xz ]] ||
     [[ $i == */bluetooth.ko.xz ]] ||
     [[ $i == */cec.ko.xz ]] ||
     [[ $i == */cfg80211.ko.xz ]] ||
     [[ $i == */cordic.ko.xz ]] ||
     [[ $i == */cxgb4.ko.xz ]] ||
     [[ $i == */dns_resolver.ko.xz ]] ||
     [[ $i == */failover.ko.xz ]] ||
     [[ $i == */gre.ko.xz ]] ||
     [[ $i == */ip6_udp_tunnel.ko.xz ]] ||
     [[ $i == */libarc4.ko.xz ]] ||
     [[ $i == */libcxgb.ko.xz ]] ||
     [[ $i == */lz4_compress.ko.xz ]] ||
     [[ $i == */mac80211.ko.xz ]] ||
     [[ $i == */pci-hyperv-intf.ko.xz ]] ||
     [[ $i == */rfkill.ko.xz ]] ||
     [[ $i == */vmw_vsock_virtio_transport_common.ko.xz ]] ||
     [[ $i == */vsock.ko.xz ]] ||
     [[ $i == */crypto/*.ko.xz ]] ||
     [[ $i == */sound/*.ko.xz ]] ||
     [[ $i == *virtio*.ko.xz ]] ||
     [[ $i == *serio*.ko.xz ]] ||
     [[ $i == */dma/*.ko.xz ]] ||
     [[ $i == *videobuf*.ko.xz ]] ||
     [[ $i == */regmap-spmi.ko.xz ]] ||
     [[ $i == */sdhci-pltfm.ko.xz ]] ||
     [[ $i == */hid-sjoy.ko.xz ]] ||
     [[ $i == */asn1_encoder.ko.xz ]] ||
     [[ $i == */auth_rpcgss.ko.xz ]] ||
     [[ $i == */bluetooth.ko.xz ]] ||
     [[ $i == */cec.ko.xz ]] ||
     [[ $i == */cfg80211.ko.xz ]] ||
     [[ $i == */cordic.ko.xz ]] ||
     [[ $i == */cxgb4.ko.xz ]] ||
     [[ $i == */dns_resolver.ko.xz ]] ||
     [[ $i == */failover.ko.xz ]] ||
     [[ $i == */gre.ko.xz ]] ||
     [[ $i == */ip6_udp_tunnel.ko.xz ]] ||
     [[ $i == */libarc4.ko.xz ]] ||
     [[ $i == */libcxgb.ko.xz ]] ||
     [[ $i == */libdes.ko.xz ]] ||
     [[ $i == */libpoly1305.ko.xz ]]; then
    echo "skipping: '$i'"
    continue
  fi

  if ! ssh guest@$host "/bin/bash -c '[ -f /$i ]'"; then
    echo "skipping: '$i'"
    continue
  fi

  if [ "$tested" == "false" ]; then
    pre="$perf"
    post="&& sudo dracut -f && sudo reboot"
  fi

  echo "removing: '$i'"
  ssh guest@$host "$pre sudo mv /$i /root/modules/ $post" || true
  if [ "$tested" == "false" ]; then
    echo "rebooting and sleeping for $s seconds"
    echo
    sleep $s
  fi
done

pre="$perf"
post="&& sudo dracut -f && sudo reboot"

ssh guest@$host "$pre true $post" || true
echo "rebooting and sleeping for $s seconds"
echo
sleep $s

ssh guest@$host "$pre true" || true

