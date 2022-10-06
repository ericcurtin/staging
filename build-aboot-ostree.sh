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

task3() {
  cd ~/git/ostree/
  rm -rf *.tar.xz
  tar -cJf libostree-2022.5.tar.xz *
  cp * /home/ecurtin/rpmbuild/SOURCES/ || true
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/ostree*.src.rpm
  rpmbuild -bs ostree.spec
}

sudo rm -rf /var/lib/mock/centos-stream+epel-9-aarch64/result
cd /home/ecurtin/rpmbuild/SOURCES/
# task1 &
# task2 &
task3 &
wait

if false; then
sudo mock -r centos-stream+epel-9-aarch64 --rebuild /home/ecurtin/rpmbuild/SRPMS/aboot-update-0.1-2.fc36.src.rpm
cp /var/lib/mock/centos-stream+epel-9-aarch64/result/* /home/ecurtin/rpmbuild/RPMS/
sudo mock -a https://buildlogs.centos.org/9-stream/automotive/aarch64/packages-main/ -a https://buildlogs.centos.org/9-stream/autosd/aarch64/packages-main/ -r centos-stream+epel-9-aarch64 --rebuild /home/ecurtin/rpmbuild/SRPMS/autosig-qemu-dtb-0.1-3.fc36.src.rpm
cp /var/lib/mock/centos-stream+epel-9-aarch64/result/* /home/ecurtin/rpmbuild/RPMS/
fi

sudo mock -a https://buildlogs.centos.org/9-stream/automotive/aarch64/packages-main/ -a https://buildlogs.centos.org/9-stream/autosd/aarch64/packages-main/ -r centos-stream+epel-9-aarch64 --rebuild /home/ecurtin/rpmbuild/SRPMS/ostree*.fc36.src.rpm
cp /var/lib/mock/centos-stream+epel-9-aarch64/result/* /home/ecurtin/rpmbuild/RPMS/

cd /home/ecurtin/rpmbuild/RPMS/
sudo createrepo .

