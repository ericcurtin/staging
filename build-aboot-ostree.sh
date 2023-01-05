#!/bin/bash

set -ex

USER=$(id -un)
GID=$(id -g)
GROUP=$(id -gn)
uname_m=$(uname -m)
usergroupadd="groupadd -g $GID $GROUP && useradd -M -s /bin/bash -g $GID -u $UID $USER"

nohup sudo dnf clean all &

rpmbuild_dir="/root/rpmbuild/RPMS"

build-aboot-update() {
  cp ~/git/aboot-update/* /home/ecurtin/rpmbuild/SOURCES/
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/aboot-update-0.1-2.*.src.rpm
  rpmbuild -bs aboot-update.spec
  sudo podman run --rm --privileged -v /home/ecurtin/rpmbuild/:/home/ecurtin/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb /home/ecurtin/rpmbuild/SRPMS/aboot-update-0.1-2.*.src.rpm && cp $rpmbuild_dir/*/* /home/ecurtin/rpmbuild/RPMS/"
}

build-autosig-qemu-dtb() {
  cp ~/git/autosig-qemu-dtb/* /home/ecurtin/rpmbuild/SOURCES/
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/autosig*.src.rpm
  rpmbuild -bs autosig-qemu-dtb.spec
  sudo podman run --rm --privileged -v /home/ecurtin/rpmbuild/:/home/ecurtin/rpmbuild/ -ti conmock-fedora /bin/bash -c "mock -a https://buildlogs.centos.org/9-stream/automotive/$uname_m/packages-main/ -a https://buildlogs.centos.org/9-stream/autosd/$uname_m/packages-main/ -r centos-stream+epel-9-$uname_m --rebuild --resultdir /var/lib/mock/centos-stream+epel-9-$uname_m/autosig-qemu-dtb/ /home/ecurtin/rpmbuild/SRPMS/autosig-qemu-dtb-0.1-3.*.src.rpm && cp /var/lib/mock/centos-stream+epel-9-$uname_m/autosig-qemu-dtb/* /home/ecurtin/rpmbuild/RPMS/"
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
  sudo podman run --rm --privileged -v /home/ecurtin/rpmbuild/:/home/ecurtin/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb /home/ecurtin/rpmbuild/SRPMS/ostree*.*.src.rpm && cp $rpmbuild_dir/*/* /home/ecurtin/rpmbuild/RPMS" &
  sudo mock --rebuild /home/ecurtin/rpmbuild/SRPMS/ostree*.*.src.rpm
  sudo rpm -Uvh --force /var/lib/mock/*-$uname_m/result/ostree-2*.*.*.$uname_m.rpm /var/lib/mock/*-$uname_m/result/ostree-libs-2*.*.*.$uname_m.rpm
  wait
}

build-aboot-deploy() {
  cd ~/git/aboot-deploy
  cp * /home/ecurtin/rpmbuild/SOURCES/
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/aboot-deploy*.src.rpm
  rpmbuild -bs aboot-deploy.spec
  sudo podman run --rm --privileged -v /home/ecurtin/rpmbuild/:/home/ecurtin/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb /home/ecurtin/rpmbuild/SRPMS/aboot-deploy*.*src.rpm && cp $rpmbuild_dir/*/* /home/ecurtin/rpmbuild/RPMS"
}

build-osbuild-aboot() {
  cd ~/git/osbuild-aboot
  cp * /home/ecurtin/rpmbuild/SOURCES/
  sudo rm -rf /home/ecurtin/rpmbuild/SRPMS/osbuild-aboot*.src.rpm
  rpmbuild -bs osbuild-aboot.spec
  sudo podman run --rm --privileged -v /home/ecurtin/rpmbuild/:/home/ecurtin/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb /home/ecurtin/rpmbuild/SRPMS/osbuild-aboot*.src.rpm && cp $rpmbuild_dir/*/* /home/ecurtin/rpmbuild/RPMS"
}

cd ~/git/staging
sudo podman build -t conmock -f Mockfile &
sudo podman build -t conmock-fedora -f Mockfile-fedora &

wait

sudo rm -rf /var/lib/mock/centos-stream+epel-9-$uname_m/result
mkdir -p /home/ecurtin/rpmbuild/SOURCES/
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

