#!/bin/bash

set -ex

# perhaps we should mandate the user specify the device
#usb_device='/dev/sda'
mkosi_rootfs='mkosi.rootfs'
mnt_usb='mnt_usb'

EFI_UUID='63B3-966B'
BOOT_UUID='e4e7b4b5-5148-4f90-86dd-07104b0b6d84'
ROOT_UUID='eb5d68f6-d401-4074-aad1-4fdd7cb89558'

# uncomment to randomize the UUID's
#EFI_UUID=$(uuidgen | tr '[a-z]' '[A-Z]' | cut -c1-8 | fold -w4 | paste -sd '-')
#BOOT_UUID=$(uuidgen)
#ROOT_UUID=$(uuidgen)


if [ "$(whoami)" != 'root' ]; then
    echo "You must be root to run this script."
    exit 1
fi


# specify the usb device with the -d argument
while getopts :d:w arg
do
    case "${arg}" in
        d) usb_device=${OPTARG};;
        w) wipe=true ;;
    esac
done


mount_usb() {
    # mounts an existing usb drive to mnt_usb/ so you can inspect the contents or chroot into it...etc
    echo '### Mounting usb partitions'
    # first try to mount the usb partitions via their uuid
    if [ $(blkid | grep -Ei "$EFI_UUID|$BOOT_UUID|$ROOT_UUID" | wc -l) -eq 3 ]; then
        [[ -z "$(findmnt -n $mnt_usb/root)" ]] && mount -U $ROOT_UUID $mnt_usb/root
        [[ -z "$(findmnt -n $mnt_usb/boot)" ]] && mount -U $BOOT_UUID $mnt_usb/boot
        [[ -z "$(findmnt -n $mnt_usb/efi)" ]] && mount -U $EFI_UUID $mnt_usb/efi
    else
        # otherwise mount via the device id
        if [ -z $usb_device ]; then
            echo -e "\nthe usb device can't be mounted via the uuid values"
            echo -e "\ntherefore you must specify the usb device ie\n./build.sh -d /dev/sda mount\n"
            exit
        fi
        [[ -z "$(findmnt -n $mnt_usb/root)" ]] && mount "$usb_device"3 $mnt_usb/root
        [[ -z "$(findmnt -n $mnt_usb/boot)" ]] && mount "$usb_device"2 $mnt_usb/boot
        [[ -z "$(findmnt -n $mnt_usb/efi)" ]] && mount "$usb_device"1 $mnt_usb/efi
    fi
}

umount_usb() {
    # unmounts usb drive from mnt_usb/
    echo '### Checking to see if usb drive is mounted'
    if [ ! "$(findmnt -n $mnt_usb)" ]; then
        return
    fi

    echo '### Unmounting usb partitions'
    [[ "$(findmnt -n $mnt_usb/boot/efi)" ]] && umount $mnt_usb/boot/efi
    [[ "$(findmnt -n $mnt_usb/boot)" ]] && umount $mnt_usb/boot
    [[ "$(findmnt -n $mnt_usb)" ]] && umount $mnt_usb
}

wipe_usb() {
    # wipe the contents of the usb drive to avoid having to repartition it

    # first check if the paritions exist
    if [ $(blkid | grep -Ei "$EFI_UUID|$BOOT_UUID|$ROOT_UUID" | wc -l) -eq 3 ]; then
        [[ -z "$(findmnt -n $mnt_usb)" ]] && mount -U $ROOT_UUID $mnt_usb
        if [ -e $mnt_usb/boot ]; then
            [[ -z "$(findmnt -n $mnt_usb/boot)" ]] && mount -U $BOOT_UUID $mnt_usb/boot
        fi
        if [ -e $mnt_usb/boot/efi ]; then
            [[ -z "$(findmnt -n $mnt_usb/boot/efi)" ]] && mount -U $EFI_UUID $mnt_usb/boot/efi
        fi
    fi

    if [ ! "$(findmnt -n $mnt_usb)" ]; then
        echo -e '### The usb drive did not mount\nparitioning disk\n'
        wipe=false
        return
    fi

    echo '### Wiping usb partitions'
    [[ "$(findmnt -n $mnt_usb/boot/efi)" ]] && rm -rf $mnt_usb/boot/efi/* && umount $mnt_usb/boot/efi
    [[ "$(findmnt -n $mnt_usb/boot)" ]] &&  rm -rf $mnt_usb/boot/* && umount $mnt_usb/boot
    [[ "$(findmnt -n $mnt_usb)" ]] && rm -rf $mnt_usb/* && umount $mnt_usb
}

# ./build.sh mount
#  or
# ./build.sh umount
#  to mount or unmount a usb drive (that was previously created by this script) to/from mnt_usb/
if [[ $1 == 'mount' ]]; then
    mount_usb
    exit
elif [[ $1 == 'umount' ]] || [[ $1 == 'unmount' ]]; then
    umount_usb
    exit
fi


[[ -z $usb_device ]] && echo -e "\nyou must specify a usb device ie\n./build.sh -d /dev/sda\n" && exit
[[ ! -e $usb_device ]] && echo -e "\n$usb_device doesn't exist\n" && exit

prepare_usb_device() {
    umount_usb
    is_mounted=$(lsblk -no MOUNTPOINT $usb_device | sed '/^$/d')
    [[ -n "$is_mounted" ]] && echo -e "\n### The usb drive is currently mounted here\n\n$(lsblk $usb_device)\n\n### Please unmount the drive and then re-run the script\n" && exit
    echo '### Preparing USB device'
    # create 5GB root partition
    #echo -e 'o\ny\nn\n\n\n+600M\nef00\nn\n\n\n+1G\n8300\nn\n\n\n+5G\n8300\nw\ny\n' | gdisk "$usb_device"
    # root partition will take up all remaining space
    echo -e 'o\ny\nn\n\n\n+600M\nef00\nn\n\n\n+1G\n8300\nn\n\n\n\n8300\nw\ny\n' | gdisk $usb_device
    mkfs.vfat -F 32 -n 'EFI-USB-FED' -i $(echo $EFI_UUID | tr -d '-') "$usb_device"1 &
    mkfs.ext4 -O '^metadata_csum' -U $BOOT_UUID -L 'fedora-usb-boot' -F "$usb_device"2 &
    mkfs.ext4 -O '^metadata_csum' -U $ROOT_UUID -L 'fedora-usb-root' -F "$usb_device"3 &
    wait

    if [ $(blkid | grep -Ei "$EFI_UUID|$BOOT_UUID|$ROOT_UUID" | wc -l) -ne 3 ]; then
        echo -e "\nthe partitions and/or filesystem were not created correctly on $usb_device\nexiting\n"
        exit
    fi
}

install_usb() {
    dd if=root.img of=${usb_device}3 status=progress &
    dd if=boot.img of=${usb_device}2 status=progress &
    rsync -aHAX esp/EFI $mnt_usb/efi/ &
    wait
    sync

    # if  $mnt_usb is mounted, then unmount it
    [[ "$(findmnt -n $mnt_usb/root)" ]] && umount $mnt_usb/root
    [[ "$(findmnt -n $mnt_usb/boot)" ]] && umount $mnt_usb/boot
    [[ "$(findmnt -n $mnt_usb/efi)" ]] && umount $mnt_usb/efi

    echo '### Unmounting usb partitions'
    umount $mnt_usb/root
    umount $mnt_usb/boot
    umount $mnt_usb/efi
    echo '### Done'
}

# if -w argument is specified
# ie
# ./build.sh -wd /dev/sda
# and the disk partitions already exist (from a previous install)
# then remove the files from disk vs repartitioning it
[[ $wipe = true ]] && wipe_usb || prepare_usb_device
mkdir -p $mnt_usb/root $mnt_usb/boot $mnt_usb/efi
install_usb

