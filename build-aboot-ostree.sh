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
  cp ~/git/aboot-update/* /home/$USER/rpmbuild/SOURCES/
  sudo rm -rf /home/$USER/rpmbuild/SRPMS/aboot-update-*.src.rpm
  rpmbuild -bs aboot-update.spec
  sudo podman run --rm --privileged -v /home/$USER/rpmbuild/:/home/$USER/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb /home/$USER/rpmbuild/SRPMS/aboot-update-*.src.rpm && cp $rpmbuild_dir/*/* /home/$USER/rpmbuild/RPMS/"
}

build-autosig-qemu-dtb() {
if true; then # re-build for additional AB functionality
# if false; then # attempted re-build for x86
  cd /home/$USER/rpmbuild/SOURCES
  curl -OL https://source.denx.de/u-boot/u-boot/-/archive/v2022.07/u-boot-v2022.07.tar.gz
  cp  ~/git/autosig-u-boot/* /home/$USER/rpmbuild/SOURCES/
  sudo rm -rf /home/$USER/rpmbuild/SRPMS/autosig-u-boot*.src.rpm
  rpmbuild -bs autosig-u-boot.spec
  sudo podman run --rm --privileged -v /home/$USER/rpmbuild/:/home/$USER/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb /home/$USER/rpmbuild/SRPMS/autosig-u-boot*.*.*.src.rpm && cp $rpmbuild_dir/*/* /home/$USER/rpmbuild/RPMS/"
  TMPDIR=$(mktemp -d)
  rpm2cpio /home/$USER/rpmbuild/RPMS/autosig-u-boot*.rpm | cpio -id -D $TMPDIR
  mv $TMPDIR/boot/u-boot.bin /home/$USER/git/sample-images/osbuild-manifests/qemu-u-boot-aarch64.bin
  rm -rf $TMPDIR
fi

  cp ~/git/autosig-qemu-dtb/* /home/$USER/rpmbuild/SOURCES/
  sudo rm -rf /home/$USER/rpmbuild/SRPMS/autosig-qemu-dtb*.src.rpm
  rpmbuild -bs autosig-qemu-dtb.spec
  sudo podman run --rm --privileged -v /home/$USER/rpmbuild/:/home/$USER/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb /home/$USER/rpmbuild/SRPMS/autosig-qemu-dtb-*.*.*.src.rpm && cp $rpmbuild_dir/*/* /home/$USER/rpmbuild/RPMS/"
}

build-ostree() {
  cd ~/git/ostree/
  rm -rf *.tar.xz
  rm -rf /home/$USER/rpmbuild/SOURCES/libostree*
  mkdir -p /home/$USER/rpmbuild/SOURCES/libostree-2022.5
  git submodule update --init
  cp -r * /home/$USER/rpmbuild/SOURCES/libostree-2022.5/
  cp -r *.spec /home/$USER/rpmbuild/SOURCES/
  cd /home/$USER/rpmbuild/SOURCES/
  tar -cJf libostree-2022.5.tar.xz libostree-2022.5
  sudo rm -rf /home/$USER/rpmbuild/SRPMS/ostree*.src.rpm
  rpmbuild -bs ostree.spec
  sudo podman run --rm --privileged -v /home/$USER/rpmbuild/:/home/$USER/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb /home/$USER/rpmbuild/SRPMS/ostree*.*.src.rpm && cp $rpmbuild_dir/*/* /home/$USER/rpmbuild/RPMS" &
  sudo mock --rebuild /home/$USER/rpmbuild/SRPMS/ostree*.*.src.rpm
  mockdir="/var/lib/mock/*-$uname_m/result"
  sudo rpm -Uvh --force $mockdir/ostree-2*.*.*.$uname_m.rpm $mockdir/ostree-libs-2*.*.*.$uname_m.rpm $mockdir/ostree-devel-2*.*.*.$uname_m.rpm
  wait
}

build-aboot-deploy() {
  cd ~/git/aboot-deploy
  cp * /home/$USER/rpmbuild/SOURCES/
  sudo rm -rf /home/$USER/rpmbuild/SRPMS/aboot-deploy*.src.rpm
  rpmbuild -bs aboot-deploy.spec
  sudo podman run --rm --privileged -v /home/$USER/rpmbuild/:/home/$USER/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb /home/$USER/rpmbuild/SRPMS/aboot-deploy*.*src.rpm && cp $rpmbuild_dir/*/* /home/$USER/rpmbuild/RPMS"
}

build-osbuild-aboot() {
  cd ~/git/osbuild-aboot
  cp * /home/$USER/rpmbuild/SOURCES/
  sudo rm -rf /home/$USER/rpmbuild/SRPMS/osbuild-aboot*.src.rpm
  rpmbuild -bs osbuild-aboot.spec
  sudo podman run --rm --privileged -v /home/$USER/rpmbuild/:/home/$USER/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb /home/$USER/rpmbuild/SRPMS/osbuild-aboot*.src.rpm && cp $rpmbuild_dir/*/* /home/$USER/rpmbuild/RPMS"
}

cd ~/git/staging
sudo podman build -t conmock -f Mockfile &
sudo podman build -t conmock-fedora -f Mockfile-fedora &

wait

sudo rm -rf /var/lib/mock/centos-stream+epel-9-$uname_m/result
mkdir -p /home/$USER/rpmbuild/SOURCES/
cd /home/$USER/rpmbuild/SOURCES/
# in review, whole manifest https://gitlab.com/CentOS/automotive/sample-images/-/merge_requests/135
build-aboot-update & # in review https://gitlab.com/CentOS/automotive/rpms/aboot-update/-/merge_requests/1
build-autosig-qemu-dtb & # in review https://gitlab.com/CentOS/automotive/rpms/autosig-qemu-dtb/-/merge_requests/1
build-ostree & # merged https://github.com/ostreedev/ostree/pull/2793
build-aboot-deploy & # merged https://gitlab.com/CentOS/automotive/rpms/aboot-deploy/-/commit/1ba3a334507bb04d5b9c29a32a96534da9c50cf4
build-osbuild-aboot & # Need to create repo
wait

sudo rpm -Uvh --force /home/$USER/rpmbuild/RPMS/osbuild-aboot*.noarch.rpm &

cd /home/$USER/rpmbuild/RPMS/
sudo rm -rf repodata
sudo createrepo .

wait

