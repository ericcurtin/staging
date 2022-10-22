#!/bin/bash

set -x

EPOCH=$(date +%s)
../../staging/build-aboot-ostree.sh > build-aboot-ostree$EPOCH.txt 2>&1

if [ "$RET" -eq "0" ] || [ "$RET" -eq "1" ]; then
  set -e
  sudo make cs9-abootqemu-minimal-ostree.aarch64.qcow2 > ~/abootqemu-ostree$EPOCH.txt 2>&1
fi

exit $?

