#!/bin/bash

set -ex

un=$(id -un)

cd ~/git/sample-images/
EPOCH=$(date +%s)
../staging/build-aboot-ostree.sh > ~/build-aboot-ostree$EPOCH.txt 2>&1

# type_img="qemu-minimal-ostree"
# type_img="abootqemu-minimal-ostree"
# type_img="abootqemu-minimal-regular"
uname_m=$(uname -m)

makes() {
  cd $type_img/osbuild-manifests
  sudo make $img $ostree_repo > ~/$img$EPOCH.txt 2>&1
  if [ -n "$img_repo" ]; then
    sudo make $img_repo DEFINES='extra_rpms=["git"] distro_version="9.9"' $ostree_repo
  fi

#  if [[ "$type_img" == aboot* ]]; then
#    img="cs9-$type_img.$uname_m.ext4"
#    sudo make $img $ostree_repo > ~/$img$EPOCH.txt 2>&1
#    rm -rf mnt
#    dev=$(sudo losetup --show -fP $img)
#    mkdir -p mnt
#    sudo mount $dev mnt
#    ls -ltr mnt
#    sudo umount mnt
#    sudo losetup -d $dev
#    img="cs9-$type_img.$uname_m.aboot"
#    sudo make $img $ostree_repo > ~/$img$EPOCH.txt 2>&1
#    if [ -n "$img_repo" ]; then
#      sudo make $img_repo DEFINES='extra_rpms=["git"] distro_version="9.1"' $ostree_repo
#    fi
#  fi
}

images=("ridesx4-minimal-ostree")
# images=("qemu-minimal-ostree")

# for type_img in abootqemu-minimal-ostree abootqemu-minimal-regular qemu-minimal-ostree qemu-minimal-regular; do
for type_img in ${images[@]}; do
  mkdir -p $type_img
  for i in $(git ls-files | awk -F/ '{print $1}' | uniq); do
    cp -r $i $type_img/ &
  done
done

wait

pre_img_name="cs9"

# for type_img in abootqemu-minimal-ostree abootqemu-minimal-regular qemu-minimal-ostree qemu-minimal-regular; do
for type_img in ${images[@]}; do
# for type_img in qdrive3-minimal-regular qdrive3-minimal-ostree abootqemu-minimal-ostree abootqemu-minimal-regular; do
# img="$pre_img_name-$type_img.$uname_m.qcow2"
  img="$pre_img_name-$type_img.$uname_m.aboot.simg"

  if [[ "$type_img" == *-ostree ]]; then
    ostree_repo="OSTREE_REPO=$type_img-repo"
    img_repo="$pre_img_name-$type_img.$uname_m.repo"
  fi

  makes &
# sudo make $pre_img_name-abootqemu-minimal-ostree.aarch64.qcow2 > ~/abootqemu-ostree$EPOCH.txt 2>&1
# sudo make $img DEFINES='extra_repos=[{"id":"extra","baseurl":"file:///home/ecurtin/rpmbuild/RPMS/"}]' > ~/$type_img$EPOCH.txt 2>&1
# /bin/bash -c "sudo make $img $ostree_repo > ~/$type_img$EPOCH.txt 2>&1 && sudo make $img_repo DEFINES='extra_rpms=[\"git\"] distro_version=\"9.1\"' OSTREE_REPO=ostree-repo" &
done

wait

sudo chown $un:$un */$pre_img_name-*.qcow2

