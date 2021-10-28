#!/bin/bash

set -e

prompt_and_read() {
  if [ -z "$2" ]; then
    sudo fdisk -l | grep -A2 "/dev/m\|/dev/s" | sed "s/://g"
    echo
    read -p "Disk to write to: " disk
    echo
    echo "Writing $1 to $disk"
    echo
  else
    disk=$2
  fi
}

if [[ $1 == *.raw.xz ]]; then
#  xzcat $1 | sudo dd bs=4M iflag=fullblock oflag=direct status=progress of=/dev/mmcblk0
  prompt_and_read $1 $2
  efi=$3
  if [ -z "$efi" ]; then
    echo ".zip files in current directory: "
    echo
    ls *.zip
    echo
    read -p "efi to flash: " efi
  fi

  echo "yes" | sudo fedora-arm-image-installer --image=$1 --media=$disk --addkey=$HOME/.ssh/id_rsa.pub --resizefs --showboot --target=rpi4 --addconsole -y
  echo "Completed write to $disk"
  if [ -n "$efi" ]; then
    fw_file=$(realpath $efi)
    if [[ $efi == *.zip ]]; then
      dev="$(sudo fdisk -l | grep "$disk" | grep FAT | awk '{print $1}')"
      sudo mkdir -p /tmp$dev
      sudo mount $dev /tmp$dev
      cd /tmp$dev
      sudo unzip -o $fw_file
      cd -
      sudo umount /tmp$dev
      sudo rm -rf /tmp$dev
    else
      echo "Unrecognized extension in filename $efi"
    fi
  fi
elif [[ $1 == *.iso ]]; then
  prompt_and_read $1 $2
  sudo dd of=$disk if=$1 bs=4M conv=fdatasync status=progress
  echo "Completed write to $disk"
else
  echo "Unrecognized extension in filename $1"
fi

sudo sync

