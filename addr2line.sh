#!/bin/bash

set -e

#addr2line -f -p -e build/examples/perf 0x60942

echo
echo "$1" | while read line ; do
  bin=$(echo "$line" | awk -F'(' '{printf $1}')
  addr=$(echo "$line" | grep -o -P '(?<=\+).*(?=\))')

#  echo "bin: $bin"
#  echo "addr: $addr"
  a2l=$(addr2line -f -p -e $bin $addr)
  if echo $a2l | grep -q "??"; then
    echo $line
  else
    echo $a2l
  fi
done

#build/examples/perf(+0x42f29)



