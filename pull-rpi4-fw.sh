#!/bin/bash

PROJECT_URL="https://github.com/pftf/RPi4"
RPI_FIRMWARE_URL="https://github.com/raspberrypi/firmware/"
ARCH="AARCH64"
COMPILER="GCC5"
GCC5_AARCH64_PREFIX="aarch64-linux-gnu-"
START_ELF_VERSION="master"
DTB_VERSION="master"
DTBO_VERSION="master"

mkdir -p overlays
curl -O -L $RPI_FIRMWARE_URL/raw/$START_ELF_VERSION/boot/fixup4.dat
curl -O -L $RPI_FIRMWARE_URL/raw/$START_ELF_VERSION/boot/start4.elf
curl -O -L $RPI_FIRMWARE_URL/raw/$DTB_VERSION/boot/bcm2711-rpi-4-b.dtb
curl -O -L $RPI_FIRMWARE_URL/raw/$DTB_VERSION/boot/bcm2711-rpi-cm4.dtb
curl -O -L $RPI_FIRMWARE_URL/raw/$DTB_VERSION/boot/bcm2711-rpi-400.dtb
curl -O -L $RPI_FIRMWARE_URL/raw/$DTBO_VERSION/boot/overlays/miniuart-bt.dtbo
curl -O -L $RPI_FIRMWARE_URL/raw/$DTBO_VERSION/boot/overlays/upstream-pi4.dtbo

