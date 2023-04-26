#!/bin/bash

for i in $(git branch | awk '{print $NF}'); do
  echo $i
  git log --pretty=format:"%<(9)%h%<(14,trunc)%ae %<(17)%ad%s" --date=format:"%F %H:%M" -1 $i -- | cut -c -80
  echo
done

