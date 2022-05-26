#!/bin/bash

set -ex

cam_num=$(cam -l 2>&1 | grep -i logitech | awk -F':' '{printf $1"\n"}')

cam -c$cam_num -S -C0

