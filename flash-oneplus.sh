#!/bin/bash

sudo fastboot flash boot mobian-oneplus6-phosh-20220116.boot-enchilada.img
sudo fastboot flash -S 100M userdata mobian-oneplus6-phosh-20220116.root.img
sudo fastboot erase dtbo

img="20220209-1348-postmarketOS-edge-phosh-15-oneplus-enchilada"
sudo fastboot flash boot $img-boot.img
sudo fastboot flash -S 10M userdata $img.img # 100M means 100M chunks
sudo fastboot erase dtbo

sudo fastboot flash boot 
sudo fastboot flash -S 10M userdata mobian-oneplus6-phosh-20220116.root.img
sudo fastboot erase dtbo

#sudo fastboot -S 100M flash userdata mobian-oneplus6-phosh-20220116.root.img

sudo fastboot format system
pmbootstrap flasher flash_kernel && pmbootstrap flasher flash_rootfs

