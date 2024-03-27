#!/bin/bash

set -e

if true; then
true > initrd.txt
true > initoverlayfs.txt
true > rootfs.txt
fi

text="Early service started"
#size=68
#size="$(echo "$i * 8" | bc)"
for i in {1..32} ; do
  initramfstime=$(grep -m1 -i "$text" "initrd$i.txt" | sed "s/\[//g" | sed "s/\]//g" | awk "{print \$1}")
  initoverlayfstime=$(grep -m1 -i "$text" "initoverlayfs$i.txt" | sed "s/\[//g" | sed "s/\]//g" | awk "{print \$1}")
  rootfstime=$(grep -m1 -i "$text" "rootfs$i.txt" | sed "s/\[//g" | sed "s/\]//g" | awk "{print \$1}")
#  initramfstime_systemd_after_switch_root=$(grep -m2 -i "systemd 2" "initrd-$i.txt" | tail -n1 | sed "s/\[//g" | sed "s/\]//g" | awk "{print \$1}")
#  initoverlayfstime_systemd_after_switch_root=$(grep -m2 -i "systemd 2" "initoverlayfs-$i.txt" | tail -n1 | sed "s/\[//g" | sed "s/\]//g" | awk "{print \$1}")
#  initramfstime=$(grep -m1 -i "Reached target initrd-switch-root" legacy-plus-data$i.txt | awk "{print \"$size \"\$1}")
#  initoverlayfstime=$(grep -m1 -i "starting kmod" initoverlayfs$i.txt | awk "{print \$1}")
#  initramfstime=$(grep -m1 -i "starting kmod" legacy-plus-data$i.txt | awk "{print \$1}")
  echo "${i}0 $initoverlayfstime" >> initoverlayfs.txt
  echo "${i}0 $initramfstime" >> initrd.txt
  echo "${i}0 $rootfstime" >> rootfs.txt

#  echo "initoverlayfstime: $initoverlayfstime initramfstime: $initramfstime"
#  if (( $(echo "$initramfstime > $initoverlayfstime" | bc -l) )); then
#    echo "initoverlayfs is faster"
#  else
#    echo "initramfs is faster"
#  fi
done

if true; then
t="png"
echo "set terminal $t
set output 'rootfs-vs-initrd-vs-initoverlayfs.$t'
set xlabel 'MB'
set ylabel 'seconds'
set key at graph 1, 1

plot 'rootfs.txt' using 1:(\$2/1) title 'rootfs - early service started' with lines lw 2, \
     'initrd.txt' using 1:(\$2/1) title 'initrd - early service started' with lines lw 2, \
     'initoverlayfs.txt' using 1:(\$2/1) title 'initoverlayfs - early service started' with lines lw 2" \
  | gnuplot
fi

