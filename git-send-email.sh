#!/bin/bash

set -ex

if grep -q "project('libcamera'" meson.build; then
  git send-email --to="libcamera-devel@lists.libcamera.org" $1
fi

