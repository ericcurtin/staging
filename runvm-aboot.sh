#!/bin/bash

set -ex

cd ~/git/sample-images/osbuild-manifests

taskset -c 4-7 ./runvm --publish-dir=cs9-$1-repo --aboot --nographics cs9-$1.aarch64.qcow2 -smp 4

