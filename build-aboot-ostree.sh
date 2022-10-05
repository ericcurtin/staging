#!/bin/bash

set -ex

nohup sudo dnf clean all &

task1() {
  cp ~/git/aboot-update/* /home/ecurtin/rpmbuild/SOURCES/
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/aboot-update-0.1-2.fc36.src.rpm
  rpmbuild -bs aboot-update.spec
}

task2() {
  cp ~/git/autosig-qemu-dtb/* /home/ecurtin/rpmbuild/SOURCES/
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/autosig*.src.rpm
  rpmbuild -bs autosig-qemu-dtb.spec
}

sudo rm -rf /var/lib/mock/centos-stream+epel-9-aarch64/result
cd /home/ecurtin/rpmbuild/SOURCES/
task1 &
task2 &
wait
sudo mock -r centos-stream+epel-9-aarch64 --rebuild /home/ecurtin/rpmbuild/SRPMS/aboot-update-0.1-2.fc36.src.rpm
sudo mock -a https://buildlogs.centos.org/9-stream/automotive/aarch64/packages-main/ -a https://buildlogs.centos.org/9-stream/autosd/aarch64/packages-main/ -r centos-stream+epel-9-aarch64 --rebuild /home/ecurtin/rpmbuild/SRPMS/autosig-qemu-dtb-0.1-2.fc36.src.rpm

cd /var/lib/mock/centos-stream+epel-9-aarch64/result
sudo createrepo .

