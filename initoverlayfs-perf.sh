#!/bin/bash

set -ex

failure() {
  local lineno=$1
  local msg=$2
  echo "Failed at $lineno: $msg"
}

trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

convert_file() {
  file="$1"

  touch $file.bak

  while read j; do
    first_word=$(echo "$j" | awk '{print $1}')
    rest_of_line=$(echo "$j" | sed 's/[^ ]* //')
    difference=$(echo  "$first_word - $preboot_time" | bc)
    echo "$difference $rest_of_line" >> $file.bak
  done < $file

  mv $file.bak $file
}

pkill qemu || true

#cd ~/git/sample-images/osbuild-manifests
#cp f38-qemu-developer-regular.aarch64.qcow2 f38.qcow2
#taskset -c 4-7 ./runvm --aboot --nographics f38-qemu-developer-regular.aarch64.qcow2 > /dev/null 2>&1 &
#sleep 32
#sshpass -p password ssh-copy-id -p 2222 root@127.0.0.1
#ssh -p2222 root@127.0.0.1 "dracut --lz4 -v -f --strip -f -M & dnf install -y */mkfs.erofs; wait; init 0"
#cd -

set +x

if false; then
for i in {1..256}; do
  cd ~/git/sample-images/osbuild-manifests
  wait
  cp cs9-qemu-developer-regular.x86_64-some-setup.qcow2 demo.qcow2
  preboot_time=$(date +%s.%N)
  ./runvm --nographics demo.qcow2 > /dev/null 2>&1 &
  cd -
  sleep 32
  ssh -p2222 root@127.0.0.1 "sudo journalctl --output=short-unix -b" > legacy$i.txt
  convert_file legacy$i.txt &
  ssh -p2222 root@127.0.0.1 "initoverlayfs-install"
  ssh -p2222 root@127.0.0.1 "init 0" || true # > /dev/null 2>&1

  cd ~/git/sample-images/osbuild-manifests
  wait
  preboot_time=$(date +%s.%N)
  ./runvm --nographics demo.qcow2 > /dev/null 2>&1 &
  cd -
  sleep 32
  ssh -p2222 root@127.0.0.1 "sudo journalctl --output=short-unix -b" > initoverlayfs$i.txt
  convert_file initoverlayfs$i.txt &
  ssh -p2222 root@127.0.0.1 "init 0" || true
done
fi

if false; then
for i in {1..64}; do
  cd ~/git/sample-images/osbuild-manifests
  wait
  cp f38-qemu-developer-regular.aarch64.qcow2 f38.qcow2
  preboot_time=$(date +%s.%N)
  taskset -c 4-7 ./runvm --aboot --nographics f38.qcow2 > /dev/null 2>&1 &
  cd -
  sleep 32
  ssh -p2222 root@127.0.0.1 "sudo journalctl --output=short-unix -b" > legacy$i.txt
  convert_file legacy$i.txt &
  git-push.sh -p2222 root@127.0.0.1
  ssh -p2222 root@127.0.0.1 "cd ~/git/initoverlayfs && ./build.sh"
  ssh -p2222 root@127.0.0.1 "init 0" || true # > /dev/null 2>&1

  cd ~/git/sample-images/osbuild-manifests
  wait
  preboot_time=$(date +%s.%N)
  taskset -c 4-7 ./runvm --aboot --nographics f38.qcow2 > /dev/null 2>&1 &
  cd -
  sleep 32
  ssh -p2222 root@127.0.0.1 "sudo journalctl --output=short-unix -b" > initoverlayfs$i.txt
  convert_file initoverlayfs$i.txt &
  ssh -p2222 root@127.0.0.1 "init 0" || true
done
fi

if false; then
for i in {1..16}; do
  ssh ecurtin@192.168.1.82 "sudo sudo rm -rf /etc/initoverlayfs.conf && sudo cp /home/ecurtin/git/initoverlayfs/storage-init /usr/sbin/storage-init && sudo cp /home/ecurtin/git/initoverlayfs/bin/initoverlayfs-install /usr/bin/initoverlayfs-install && sudo dracut -f -o initoverlayfs && sudo initoverlayfs-install && sudo reboot"
  sleep 100
  while ! timeout 1 ssh ecurtin@192.168.1.82 "sudo journalctl --output=short-monotonic -b" > storage-init-lz4$i.txt; do sleep 1; done
#  convert_file legacy$i.txt &
  ssh ecurtin@192.168.1.82 "sudo rm -rf /etc/initoverlayfs.conf && sudo cp /home/ecurtin/git/initoverlayfs/storage-init /usr/sbin/storage-init && sudo cp /home/ecurtin/git/initoverlayfs/bin/initoverlayfs-install-no-compression /usr/bin/initoverlayfs-install && sudo dracut -f -o initoverlayfs && sudo initoverlayfs-install && sudo reboot"
  sleep 100
  while ! timeout 1 ssh ecurtin@192.168.1.82 "sudo journalctl --output=short-monotonic -b" > storage-init-nolz4$i.txt; do sleep 1; done
#  convert_file initoverlayfs$i.txt &
done
else
for i in {1..16}; do
#  ssh ecurtin@192.168.1.82 "sudo sed -i \"s/# UUID=/UUID=/g\" /etc/fstab && sudo dracut -f -o initoverlayfs && sudo reboot"
  echo "Run number $i"
  cd ~/git/sample-images/osbuild-manifests
  cp f39-qemu-developer-regular.x86_64.qcow2 demo.qcow2
  ./runvm --nographics demo.qcow2 > /dev/null 2>&1 &
  cd ~/git/initoverlayfs
  sleep 16
  while ! timeout 1 ssh -p2222 root@127.0.0.1 "journalctl --output=short-monotonic -b" > storage-init-initrd-$i.txt; do sleep 1; done
#  convert_file legacy$i.txt &
  git-push.sh -p2222 root@127.0.0.1
  ssh -p2222 root@127.0.0.1 "cd ~/git/initoverlayfs/ && scripts/install.sh && reboot"
  sleep 16
  while ! timeout 1 ssh -p2222 root@127.0.0.1 "journalctl --output=short-monotonic -b" > storage-init-initoverlayfs-$i.txt; do sleep 1; done
  while ! timeout 1 ssh -p2222 root@127.0.0.1 "init 0"; do sleep 1; done
#  convert_file initoverlayfs$i.txt &
done
fi



