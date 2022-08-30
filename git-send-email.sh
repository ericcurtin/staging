#!/bin/bash

set -ex

if grep -q "project('libcamera'" meson.build; then
  git send-email --to="libcamera-devel@lists.libcamera.org" $1
elif [ -f "Makefile" ] && [ -f "Kbuild" ] && [ -f "Kconfig" ]; then
  patch=$(git format-patch $1)
  scripts/checkpatch.pl $patch
  git send-email --cc-cmd='scripts/get_maintainer.pl $patch' $1
fi

