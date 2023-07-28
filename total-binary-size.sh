#!/bin/bash

bin=$(command -v $1)

du -sh $bin

for i in $(ldd $bin); do
   out=$(du -sh $i 2> /dev/null)
   if [ $? -eq 0 ]; then
     echo "  $out"
   fi
done


