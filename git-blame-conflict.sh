#!/bin/bash

git fetch > /dev/null 2>&1 &

ls_files=$(git diff --name-only --diff-filter=U)

if [ -n "$1" ]; then
  this_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

bold=$(tput bold)
norm=$(tput sgr0)

out=/tmp/git-blame-conflict-$$.lock

blame_res_cnt_func() {
  if [ -n "$blame_res" ]; then
    echo "$blame_res" | sort | uniq -c | sort -nr | head -n2
  else
    echo "        File doesn't exist on one side of branch"
  fi
}

task() {
  blame=$(git blame $i | awk '/<<<</,/>>>>/')
  blame_res=$(echo "$blame" | cut -c-32 | grep -o '..................$' | grep -v "Not Committed Yet")
  blame_res_cnt=$(blame_res_cnt_func)

  if [ -n "$this_branch" ]; then
    blame_list_of_commits=$(echo "$blame" | awk '{printf $1"\n"}' | sort | uniq | grep -v "000000000000")
    git_fmt="%<(8,trunc)%h %<(16,trunc)%an %<(8,trunc)%ar %<(45,trunc)%s"
    for j in $blame_list_of_commits; do
      if [ -n "$(git branch $this_branch --contains $j)" ]; then
        this_list="$this_list $j"
      fi
    done

    for j in $blame_list_of_commits; do
      if [ ! -n "$(git branch $this_branch --contains $j)" ]; then
        that_list="$that_list $j"
      fi
    done

    this_log=$(git log --topo-order --pretty=format:"$git_fmt" -$(echo $this_list | wc -w) $this_list)
    that_log=$(git log --topo-order --pretty=format:"$git_fmt" -$(echo $that_list | wc -w) $that_list)
  fi

  {
    flock -x 3
    printf "$bold%s$norm\n%s\n" "$i" "$blame_res_cnt"
    if [ -n "$this_branch" ]; then
      printf "%s\n\n%s\n" "$this_log" "$that_log"
    fi

    echo "$blame_res" >&3
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

echo "${bold}Total amount of lines changed per person: $norm"
cat $out | sort | uniq -c | sort -nr | head -n4
rm $out

