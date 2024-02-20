#!/bin/bash

bin=$(command -v $*)

abs_bins=""
for i in $bin; do
  abs_bins="$abs_bins$(ldd $bin)"
done

abs_bins=$(for word in $abs_bins; do echo $word; done | sort | uniq)

# echo "$abs_bins 1" | xargs

for i in $abs_bins; do
#   echo "$i 1"
   if [ -e "$i" ]; then
     readlink_bin="$(readlink $i)"
     if [ ! -z "$readlink_bin" ]; then
       dir="$(dirname $i | perl -pe 'chomp')"
       bin="$bin $dir/$readlink_bin"
     else
       bin="$bin $i"
     fi
   fi
done

#echo "$bin"
du -hc $bin

