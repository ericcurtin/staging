#!/bin/bash

xcpio() {
  if ! [ -r $1 ]; then
    echo "file not readable"
    return 0
  elif /usr/lib/dracut/skipcpio $1 | gzip -t - >/dev/null 2>&1; then
    echo "gzip"
  elif /usr/lib/dracut/skipcpio $1 | zstd -q -c -t - >/dev/null 2>&1; then
    echo "zstd"
  elif /usr/lib/dracut/skipcpio $1 | xzcat -t - >/dev/null 2>&1; then
    echo "xz"
  elif /usr/lib/dracut/skipcpio $1 | lz4cat -t - >/dev/null 2>&1; then
    echo "lz4"
  elif /usr/lib/dracut/skipcpio $1 | bzip2 -t - >/dev/null 2>&1; then
    echo "bzip2"
  elif /usr/lib/dracut/skipcpio $1 | lzop -t - >/dev/null 2>&1; then
    echo "lzo"
  else
    echo "neither"
  fi
}

xcpio "$1"

