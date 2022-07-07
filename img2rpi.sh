#!/bin/bash

set -e

prompt_and_read() {
  if [ -z "$dev" ]; then
    sudo fdisk -l | grep -A2 "/dev/m\|/dev/s\|/dev/l" | sed "s/://g"
    echo
    read -p "Disk to write to: " dev
    echo
    echo "Writing $1 to $dev"
    echo
  fi
}

dev=$2
efi=$3

read -p "Do you want to add ssh key? (y/n) " ssh_key
if [[ $ssh_key =~ ^[Yy]$ ]]; then
  ssh_key="--addkey=$HOME/.ssh/id_rsa.pub"
fi

read -p "Do you want to add extra packages? (y/n) " dnf
read -p "Do you want to setup fake device? (y/n) " fake
if [ -z "$efi" ]; then
  read -p "Do you want to flash EFI? (y/n) " flash
  if [[ $flash =~ ^[Yy]$ ]]; then
    echo ".zip files in current directory: "
    echo
    ls *EFI*.zip
    echo
    read -p "efi to flash: " efi
  fi
fi

if [[ $1 == *.raw.xz ]] || [[ $1 == *.img.xz ]]; then
#  xzcat $1 | sudo dd bs=4M iflag=fullblock oflag=direct status=progress of=/dev/mmcblk0
  if [[ $fake =~ ^[Yy]$ ]]; then
    out="16G.raw"
    dd if=/dev/zero of=~/$out bs=1G count=16
    dev=$(sudo losetup --show -fP ~/$out)
  fi

  prompt_and_read $1 $dev
  echo "yes" | sudo fedora-arm-image-installer --image=$1 --media=$dev $ssh_key --resizefs --showboot --target=rpi4 --addconsole -y
  echo "Completed write to $dev"
  if [ -n "$efi" ]; then
    fw_file=$(realpath $efi)
    if [[ $efi == *.zip ]]; then
      dev_fat="$(sudo fdisk -l | grep "$dev" | grep FAT | awk '{print $1}')"
      sudo mkdir -p $HOME/$dev_fat
      sudo mount $dev_fat $HOME/$dev_fat
      cd $HOME/$dev_fat
      sudo unzip -o $fw_file
      cd -
      sudo umount $HOME/$dev_fat
      sudo rm -rf $HOME/$dev_fat
    else
      echo "Unrecognized extension in efi filename: '$efi'"
    fi
  fi
elif [[ $1 == *.iso ]] || [[ $1 == *.img ]] || [[ $1 == *.raw ]]; then
  prompt_and_read $1 $dev
  sudo dd of=$dev if=$1 bs=4M conv=fdatasync status=progress
  echo "Completed write to $dev"
else
  echo "Unrecognized extension in image filename: '$1'"
fi

if [[ $dnf =~ ^[Yy]$ ]]; then
  dev_root="$(sudo fdisk -l | grep "$dev" | grep -v FAT | tail -n1 | awk '{print $1}')"
  sudo mkdir -p $HOME/$dev_root
  sudo mount $dev_root $HOME/$dev_root
  root="$HOME/$dev_root/root"
  sudo cp $(which qemu-aarch64-static) $root/usr/bin
  resolv="$root/etc/resolv.conf"
  hosts="$root/etc/hosts"
  sudo cp $resolv /tmp/resolv.conf
  sudo cp $hosts /tmp/hosts
  sudo /bin/bash -c "echo -e 'nameserver 8.8.8.8\nnameserver 8.8.4.4' > $resolv"
  sudo /bin/bash -c "echo -e '127.0.0.1 localhost' > $hosts"
  sudo systemd-nspawn -D $root qemu-aarch64-static /bin/env -i TERM="$TERM" \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/bin /bin/bash -c "dnf install -y \
      git gcc g++ libevent libevent-devel openssl openssl-devel gnutls \
      gnutls-devel meson boost boost-devel python3-jinja2 python3-ply \
      python3-yaml libdrm libdrm-devel doxygen cmake graphviz drm-utils \
      flex make bison elfutils-libelf-devel ncurses-devel bc tar dwarves \
      rpm-build v4l-utils"
  sudo mv /tmp/resolv.conf $resolv
  sudo mv /tmp/hosts $hosts
  sudo killall -9 /usr/bin/qemu-aarch64-static || true
  sudo rm -f $root/usr/bin/qemu-aarch64-static
  sudo umount $HOME/$dev_root
  sudo rm -rf $HOME/$dev_root
fi

if [[ $fake =~ ^[Yy]$ ]]; then
  sudo losetup -D
  img_name=$(echo $1 | sed "s/.xz//g")
  sudo mv ~/$out ~/$img_name
  printf "Compressing...\n"
  xz -9 ~/$img_name
fi

sudo sync

