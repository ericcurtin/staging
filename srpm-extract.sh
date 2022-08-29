#!/bin/bash

abs_fn=$(echo "$(cd "$(dirname -- "$1")" >/dev/null; pwd -P)/$(basename -- "$1")")
fn=$(basename $abs_fn)
dir=$(echo $fn | awk -F'.' '{print $1}')

mkdir -p $dir
cd $dir
rpm2cpio $abs_fn | cpio -idmv

