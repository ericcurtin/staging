#!/bin/bash

set -e

host="mac"

git-push.sh -p8022 ecurtin@$host
ssh -p8022 ecurtin@$host "cd ~/git/ostree-compliance-mode; meson build --buildtype=release --prefix=/var && ninja -v -C build && ninja -v -C build install && sudo ./install.sh"

