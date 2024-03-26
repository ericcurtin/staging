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
  cp ~/git/aboot-update/* $src_dir/
  sudo rm -rf $srpm_dir/aboot-update-*.src.rpm
  rpmbuild -bs aboot-update.spec
  sudo podman run --rm --privileged -v /home/$USER/rpmbuild/:/home/$USER/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb $srpm_dir/aboot-update-*.src.rpm && cp $rpmbuild_dir/*/* /home/$USER/rpmbuild/RPMS/"
}

build-autosig-qemu-dtb() {
if true; then # re-build for additional AB functionality
# if false; then # attempted re-build for x86
  cd $src_dir
  curl -OL https://source.denx.de/u-boot/u-boot/-/archive/v2022.07/u-boot-v2022.07.tar.gz
  cp  ~/git/autosig-u-boot/* $src_dir/
  sudo rm -rf $srpm_dir/autosig-u-boot*.src.rpm
  rpmbuild -bs autosig-u-boot.spec
  sudo podman run --rm --privileged -v /home/$USER/rpmbuild/:/home/$USER/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb $srpm_dir/autosig-u-boot*.*.*.src.rpm && cp $rpmbuild_dir/*/* /home/$USER/rpmbuild/RPMS/"
  TMPDIR=$(mktemp -d)
  rpm2cpio /home/$USER/rpmbuild/RPMS/autosig-u-boot*.rpm | cpio -id -D $TMPDIR
  mv $TMPDIR/boot/u-boot.bin /home/$USER/git/sample-images/osbuild-manifests/qemu-u-boot-aarch64.bin
  rm -rf $TMPDIR
fi

  cp ~/git/autosig-qemu-dtb/* $src_dir/
  sudo rm -rf $srpm_dir/autosig-qemu-dtb*.src.rpm
  rpmbuild -bs autosig-qemu-dtb.spec
  sudo podman run --rm --privileged -v /home/$USER/rpmbuild/:/home/$USER/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb $srpm_dir/autosig-qemu-dtb-*.*.*.src.rpm && cp $rpmbuild_dir/*/* /home/$USER/rpmbuild/RPMS/"
}

build-ostree() {
  cd ~/git/ostree/
  git clean -fdx
  ostree_ver="2024.6"
  git tag -f v$ostree_ver
  ./autogen.sh
  make dist
#  rm -rf *.tar.xz
  rm -rf $src_dir/libostree*
  mkdir -p $src_dir/libostree-$ostree_ver
  git submodule update --init
  cp -r * $src_dir/libostree-$ostree_ver/
  cp -r *.spec $src_dir/
  cp ostree-readonly-sysroot-m* $src_dir/
#  cp 0001-prepa* $src_dir/
#  cp -r .libs $src_dir/libostree-$ostree_ver/
  cp libostree-*.tar.xz $src_dir/
#  tar -cJf libostree-$ostree_ver.tar.xz libostree-$ostree_ver
  sudo rm -rf $srpm_dir/ostree*.src.rpm
  rpmbuild -bs ostree.spec
  sudo podman run --rm --privileged -v /home/$USER/rpmbuild/:/home/$USER/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb $srpm_dir/ostree*.*.src.rpm && cp $rpmbuild_dir/*/* /home/$USER/rpmbuild/RPMS" &
  sudo mock --rebuild $srpm_dir/ostree*.*.src.rpm
  mockdir="/var/lib/mock/*-$uname_m/result"
  sudo rpm -Uvh --force $mockdir/ostree-2*.*.*.$uname_m.rpm $mockdir/ostree-libs-2*.*.*.$uname_m.rpm
  wait
}

build-aboot-deploy() {
  cd ~/git/aboot-deploy
  cp * $src_dir/
  sudo rm -rf $srpm_dir/aboot-deploy*.src.rpm
  rpmbuild -bs aboot-deploy.spec
  sudo podman run --rm --privileged -v /home/$USER/rpmbuild/:/home/$USER/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb $srpm_dir/aboot-deploy*.*src.rpm && cp $rpmbuild_dir/*/* /home/$USER/rpmbuild/RPMS"
}

build-osbuild-aboot() {
  cd ~/git/osbuild-aboot
  cp * $src_dir/
  sudo rm -rf $srpm_dir/osbuild-aboot*.src.rpm
  rpmbuild -bs osbuild-aboot.spec
  sudo podman run --rm --privileged -v /home/$USER/rpmbuild/:/home/$USER/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb $srpm_dir/osbuild-aboot*.src.rpm && cp $rpmbuild_dir/*/* /home/$USER/rpmbuild/RPMS"
}

build-greenboot() {
  cd ~/git/greenboot
  git archive --prefix greenboot-0.15.4/ HEAD > $src_dir/v0.15.4.tar.gz
  cp -r * $src_dir/
  sudo rm -rf $srpm_dir/greenboot*.src.rpm
  rpmbuild -bs greenboot.spec
  sudo podman run --rm --privileged -v /home/$USER/rpmbuild/:/home/$USER/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb $srpm_dir/greenboot*.src.rpm && cp $rpmbuild_dir/*/* /home/$USER/rpmbuild/RPMS"
}

build-systemd() {
  cd ~/git/rpms/systemd
  cp -r * $src_dir/
  cd $src_dir
  if ! [ -e "systemd-252.tar.gz" ]; then
    curl -OL https://github.com/systemd/systemd/archive/v252/systemd-252.tar.gz
  fi

  rpmbuild -bs systemd.spec
  sudo podman run --rm --privileged -v /home/$USER/rpmbuild/:/home/$USER/rpmbuild/ -ti conmock /bin/bash -c "$usergroupadd && rpmbuild -rb $srpm_dir/systemd*.src.rpm && cp $rpmbuild_dir/*/* $rpmdir"
}

cd ~/git/staging
sudo podman build -t conmock -f Mockfile &
sudo podman build -t conmock-fedora -f Mockfile-fedora &

wait

rpmdir="/home/$USER/rpmbuild/RPMS/"
srpm_dir="/home/$USER/rpmbuild/SRPMS"
src_dir="/home/$USER/rpmbuild/SOURCES"
# sudo rm -rf $rpmdir
sudo rm -rf /var/lib/mock/centos-stream+epel-9-$uname_m/result
mkdir -p $src_dir $rpmdir
cd $src_dir/
# in review, whole manifest https://gitlab.com/CentOS/automotive/sample-images/-/merge_requests/135
build-aboot-update & # in review https://gitlab.com/CentOS/automotive/rpms/aboot-update/-/merge_requests/1
# build-autosig-qemu-dtb & # in review https://gitlab.com/CentOS/automotive/rpms/autosig-qemu-dtb/-/merge_requests/1
# build-greenboot &
# build-ostree & # merged https://github.com/ostreedev/ostree/pull/2793
# build-aboot-deploy & # merged https://gitlab.com/CentOS/automotive/rpms/aboot-deploy/-/commit/1ba3a334507bb04d5b9c29a32a96534da9c50cf4
# build-osbuild-aboot & # Need to create repo
# build-systemd &
wait

# sudo rpm -Uvh --force /home/$USER/rpmbuild/RPMS/osbuild-aboot*.noarch.rpm &

cd $rpmdir
sudo rm -rf repodata
sudo createrepo .

wait

