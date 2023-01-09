#!/bin/bash

set -x

abs_fn=$1
fn=$(basename $abs_fn)
dir=$(echo $fn | awk -F'.' '{print $1}')

mkdir -p $dir
cd $dir
rpm2cpio $abs_fn | cpio -idmv

