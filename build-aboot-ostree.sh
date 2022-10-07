#!/bin/bash

set -ex

nohup sudo dnf clean all &

task1() {
  cp ~/git/aboot-update/* /home/ecurtin/rpmbuild/SOURCES/
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/aboot-update-0.1-2.fc36.src.rpm
  rpmbuild -bs aboot-update.spec
  sudo podman run --rm --privileged -v /home/ecurtin/rpmbuild/:/home/ecurtin/rpmbuild/ -ti conmock /bin/bash -c "mock -r centos-stream+epel-9-aarch64 --rebuild --resultdir /var/lib/mock/centos-stream+epel-9-aarch64/aboot-update/ /home/ecurtin/rpmbuild/SRPMS/aboot-update-0.1-2.fc36.src.rpm && cp /var/lib/mock/centos-stream+epel-9-aarch64/aboot-update/* /home/ecurtin/rpmbuild/RPMS/"
}

task2() {
  cp ~/git/autosig-qemu-dtb/* /home/ecurtin/rpmbuild/SOURCES/
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/autosig*.src.rpm
  rpmbuild -bs autosig-qemu-dtb.spec
  sudo podman run --rm --privileged -v /home/ecurtin/rpmbuild/:/home/ecurtin/rpmbuild/ -ti conmock /bin/bash -c "mock -a https://buildlogs.centos.org/9-stream/automotive/aarch64/packages-main/ -a https://buildlogs.centos.org/9-stream/autosd/aarch64/packages-main/ -r centos-stream+epel-9-aarch64 --rebuild --resultdir /var/lib/mock/centos-stream+epel-9-aarch64/autosig-qemu-dtb/ /home/ecurtin/rpmbuild/SRPMS/autosig-qemu-dtb-0.1-3.fc36.src.rpm && cp /var/lib/mock/centos-stream+epel-9-aarch64/autosig-qemu-dtb/* /home/ecurtin/rpmbuild/RPMS/"
}

task3() {
  cd ~/git/ostree/
  rm -rf *.tar.xz
  rm -rf /home/ecurtin/rpmbuild/SOURCES/libostree-2022.5
  mkdir -p /home/ecurtin/rpmbuild/SOURCES/libostree-2022.5
  cp -r * /home/ecurtin/rpmbuild/SOURCES/libostree-2022.5/
  cd /home/ecurtin/rpmbuild/SOURCES/
  tar -cJf libostree-2022.5.tar.xz libostree-2022.5
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/ostree*.src.rpm
  rpmbuild -bs ostree.spec
  sudo podman run --rm --privileged -v /home/ecurtin/rpmbuild/:/home/ecurtin/rpmbuild/ -ti conmock /bin/bash -c "mock -a https://buildlogs.centos.org/9-stream/automotive/aarch64/packages-main/ -a https://buildlogs.centos.org/9-stream/autosd/aarch64/packages-main/ -r centos-stream+epel-9-aarch64 --rebuild --resultdir /var/lib/mock/centos-stream+epel-9-aarch64/ostree/ /home/ecurtin/rpmbuild/SRPMS/ostree*.fc36.src.rpm && cp /var/lib/mock/centos-stream+epel-9-aarch64/ostree/* /home/ecurtin/rpmbuild/RPMS"
}

cd ~/git/staging
sudo podman build -t conmock -f Mockfile

sudo rm -rf /var/lib/mock/centos-stream+epel-9-aarch64/result
cd /home/ecurtin/rpmbuild/SOURCES/
task1 &
task2 &
task3 &
wait

cd /home/ecurtin/rpmbuild/RPMS/
sudo createrepo .

