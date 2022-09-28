#!/bin/bash

set -ex

mkdir -p ~/dracut
mkdir -p ~/km

for i in $(cat dracut-module-mini.txt | awk '{print $NF}'); do
  file=$(find /usr/lib/dracut/modules.d -name "$i" | head -n1)
  mv $file ~/dracut/
done

for i in $(cat kernel-module-mini.txt | awk '{print $NF}'); do
  file=$(find /usr/lib/modules/ -name "$i" | head -n1)
  mv $file ~/km/
done

