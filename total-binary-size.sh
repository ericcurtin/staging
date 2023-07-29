#!/bin/bash

bin=$(command -v $1)

for i in $(ldd $bin); do
   if [ -e "$i" ]; then
     bin="$bin $i"
   fi
done

du -hc $bin

