#!/bin/bash

# sudo umount /dev/loop1 & sudo umount /dev/loop2 & sudo umount /dev/loop3
# wait

export TIMEFORMAT='%3R'
for i in {0..100}; do
printf "vfat\nmount time: "
time sudo mount /dev/loop2 vfat
printf "read time:  "
time sudo cat vfat/1G.txt > /dev/null
printf "erofs\nmount time: "
time sudo mount /dev/loop1 erofs
printf "read time:  "
time sudo cat erofs/1G.txt > /dev/null
printf "ext4\nmount time: "
time sudo mount /dev/loop3 ext4
printf "read time:  "
time sudo cat erofs/1G.txt > /dev/null
echo
sudo umount /dev/loop1 & sudo umount /dev/loop2 & sudo umount /dev/loop3
wait
done

