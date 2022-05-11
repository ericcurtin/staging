#!/bin/bash

for i in $1*/; do
  cd $i
  current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  printf "%-16s %s\n" "$i" "$current_branch"
  git log --pretty=format:"%<(9)%h%<(14,trunc)%ae %<(17)%ad%s" --date=format:"%F %H:%M" -1 | cut -c -80
  echo
  cd - > /dev/null
done

