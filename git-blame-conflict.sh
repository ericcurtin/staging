#!/bin/bash

ls_files=$(git diff --name-only --diff-filter=U)

out=/tmp/git-blame-conflict-$$.lock

blame_res_cnt_func() {
  if [ -n "$blame_res" ]; then
    echo "$blame_res" | sort | uniq -c | sort -nr | head -n4
  else
    echo "        File doesn't exist on one side of branch"
  fi
}

task() {
  blame_res=$(git blame $i | awk '/<<<</,/>>>>/' | cut -c-32 | grep -o '..................$' | grep -v "Not Committed Yet")
  blame_res_cnt=$(blame_res_cnt_func)

  {
    flock -x 3
    printf "%s\n%s\n\n" "$i" "$blame_res_cnt"
    echo  "$blame_res" >&3
  } 3>>$out
}

touch $out

for i in $(echo $ls_files); do
  # Max 16 processes at any given time
  while [[ $(jobs -r -p | wc -l) -gt 16 ]]; do
    sleep 1
  done

  task &
done

wait

echo "Total amount of lines changed per person: "
cat $out | sort | uniq -c | sort -nr | head -n8
rm $out

