#!/bin/bash

set -e

qemu-system-aarch64 -machine virt -m 4G -nographic -cpu cortex-a57 -bios u-boot.bin -hda $1

