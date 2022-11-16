#!/bin/bash

set -ex

nohup sudo dnf clean all &

build-aboot-update() {
  cp ~/git/aboot-update/* /home/ecurtin/rpmbuild/SOURCES/
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/aboot-update-0.1-2.*.src.rpm
  rpmbuild -bs aboot-update.spec
  sudo podman run --rm --privileged -v /home/ecurtin/rpmbuild/:/home/ecurtin/rpmbuild/ -ti conmock /bin/bash -c "mock -r centos-stream+epel-9-aarch64 --rebuild --resultdir /var/lib/mock/centos-stream+epel-9-aarch64/aboot-update/ /home/ecurtin/rpmbuild/SRPMS/aboot-update-0.1-2.*.src.rpm && cp /var/lib/mock/centos-stream+epel-9-aarch64/aboot-update/* /home/ecurtin/rpmbuild/RPMS/"
}

build-autosig-qemu-dtb() {
  cp ~/git/autosig-qemu-dtb/* /home/ecurtin/rpmbuild/SOURCES/
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/autosig*.src.rpm
  rpmbuild -bs autosig-qemu-dtb.spec
  sudo podman run --rm --privileged -v /home/ecurtin/rpmbuild/:/home/ecurtin/rpmbuild/ -ti conmock /bin/bash -c "mock -a https://buildlogs.centos.org/9-stream/automotive/aarch64/packages-main/ -a https://buildlogs.centos.org/9-stream/autosd/aarch64/packages-main/ -r centos-stream+epel-9-aarch64 --rebuild --resultdir /var/lib/mock/centos-stream+epel-9-aarch64/autosig-qemu-dtb/ /home/ecurtin/rpmbuild/SRPMS/autosig-qemu-dtb-0.1-3.*.src.rpm && cp /var/lib/mock/centos-stream+epel-9-aarch64/autosig-qemu-dtb/* /home/ecurtin/rpmbuild/RPMS/"
}

build-ostree() {
  cd ~/git/ostree/
  rm -rf *.tar.xz
  rm -rf /home/ecurtin/rpmbuild/SOURCES/libostree*
  mkdir -p /home/ecurtin/rpmbuild/SOURCES/libostree-2022.5
  git submodule update --init
  cp -r * /home/ecurtin/rpmbuild/SOURCES/libostree-2022.5/
  cp -r *.spec /home/ecurtin/rpmbuild/SOURCES/
  cd /home/ecurtin/rpmbuild/SOURCES/
  tar -cJf libostree-2022.5.tar.xz libostree-2022.5
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/ostree*.src.rpm
  rpmbuild -bs ostree.spec
  sudo podman run --rm --privileged -v /home/ecurtin/rpmbuild/:/home/ecurtin/rpmbuild/ -ti conmock /bin/bash -c "mock -a https://buildlogs.centos.org/9-stream/automotive/aarch64/packages-main/ -a https://buildlogs.centos.org/9-stream/autosd/aarch64/packages-main/ -r centos-stream+epel-9-aarch64 --rebuild --resultdir /var/lib/mock/centos-stream+epel-9-aarch64/ostree/ /home/ecurtin/rpmbuild/SRPMS/ostree*.*.src.rpm && cp /var/lib/mock/centos-stream+epel-9-aarch64/ostree/* /home/ecurtin/rpmbuild/RPMS"
  sudo mock --rebuild /home/ecurtin/rpmbuild/SRPMS/ostree*.*.src.rpm

  rm -f /var/lib/mock/*/result/*.rpm
  # install on host system
  for i in $(ls /var/lib/mock/*/result/ | grep -v ".src.rpm\|debug" | grep "ostree-l\|ostree-2"); do
    sudo rpm -Uvh --nodeps /var/lib/mock/*/result/$i
  done
}

build-aboot-deploy() {
  cd ~/git/aboot-deploy
  cp * /home/ecurtin/rpmbuild/SOURCES/
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/aboot-deploy*.src.rpm
  rpmbuild -bs aboot-deploy.spec
  sudo podman run --rm --privileged -v /home/ecurtin/rpmbuild/:/home/ecurtin/rpmbuild/ -ti conmock /bin/bash -c "mock -r centos-stream+epel-9-aarch64 --rebuild --resultdir /var/lib/mock/centos-stream+epel-9-aarch64/aboot-deploy/ /home/ecurtin/rpmbuild/SRPMS/aboot-deploy*.*src.rpm && cp /var/lib/mock/centos-stream+epel-9-aarch64/aboot-deploy/* /home/ecurtin/rpmbuild/RPMS"
}

build-osbuild-aboot() {
  cd ~/git/osbuild-aboot
  cp * /home/ecurtin/rpmbuild/SOURCES/
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/osbuild-aboot*.src.rpm
  rpmbuild -bs osbuild-aboot.spec
  sudo podman run --rm --privileged -v /home/ecurtin/rpmbuild/:/home/ecurtin/rpmbuild/ -ti conmock /bin/bash -c "mock --rebuild --resultdir /var/lib/mock/centos-stream+epel-9-aarch64/osbuild-aboot/ /home/ecurtin/rpmbuild/SRPMS/osbuild-aboot*.src.rpm && cp /var/lib/mock/centos-stream+epel-9-aarch64/osbuild-aboot/* /home/ecurtin/rpmbuild/RPMS"
}

cd ~/git/staging
sudo podman build -t conmock -f Mockfile

sudo rm -rf /var/lib/mock/centos-stream+epel-9-aarch64/result
cd /home/ecurtin/rpmbuild/SOURCES/
build-aboot-update &
build-autosig-qemu-dtb &
build-ostree &
build-aboot-deploy &
build-osbuild-aboot &
wait

sudo rpm -Uvh --force /home/ecurtin/rpmbuild/RPMS/osbuild-aboot*.noarch.rpm &

cd /home/ecurtin/rpmbuild/RPMS/
sudo rm -rf repodata
sudo createrepo .

wait

