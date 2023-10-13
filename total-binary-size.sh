#!/bin/bash

bin=$(command -v $1)

for i in $(ldd $bin); do
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

