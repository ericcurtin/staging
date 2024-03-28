!#/bin/bash

set -x

for i in lz4 lz4hc lzma deflate libdeflate; do
  for j in "" "-Ededupe" "-Eall-fragments"; do
    mkfs.erofs -z$i $j img.img .
    echo "mkfs.erofs -z$i $j"
    dev=$(sudo losetup --show -fP img.img)
    mkdir -p /tmp/tmptest
    mount $dev /tmp/tmptest
    sudo hyperfine -i --prepare 'sync; echo 3 | sudo tee /proc/sys/vm/drop_caches' 'cat /tmp/tmptest/*'
    umount /tmp/tmptest
    losetup -d $dev
    sudo rm -rf /tmp/tmptest
  done
done

