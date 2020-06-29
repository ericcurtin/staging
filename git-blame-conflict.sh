#!/bin/bash

git fetch > /dev/null 2>&1 &

ls_files=$(git diff --name-only --diff-filter=U)

if [ -z "$ls_files" ]; then
  echo "No conflicts here!"
  exit 0
fi

if [ -n "$1" ]; then
  this_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

if [ -t 1 ]; then
  bold=$(tput bold)
  norm=$(tput sgr0)
fi

out=/tmp/git-blame-conflict-$$.lock

blame_res_cnt_func() {
  if [ -n "$blame_res" ]; then
    echo "$blame_res" | sort | uniq -c | sort -nr | head -n4
  else
    echo "        File doesn't exist on one side of branch"
  fi
}

task() {
  blame=$(git blame $i | awk '/<<<</,/>>>>/')
  blame_res=$(echo "$blame" | cut -c-32 | grep -o '..................$' | grep -v "Not Committed Yet")
  blame_res_cnt=$(blame_res_cnt_func)

  if [ -n "$this_branch" ]; then
    blame_list_of_commits=$(echo "$blame" | cut -c-8 | sort | uniq | grep -v "00000000")
    git_fmt="%<(11,trunc)%h %<(16,trunc)%an %<(8,trunc)%ar %<(42,trunc)%s"
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

    if [ -n "$this_list" ]; then
      this_log=$(git log --topo-order --pretty=format:"$git_fmt" $this_list | grep "$(echo $this_list | sed 's/ /\\|/g')")
    fi

    if [ -n "$that_list" ]; then
      that_log=$(git log --topo-order --branches --pretty=format:"$git_fmt" $that_list | grep "$(echo $that_list | sed 's/ /\\|/g')")
    fi
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
  while [ $(jobs -r -p | wc -l) -gt 4 ]; do
    sleep 1
  done

  task &
done

wait

echo "${bold}Total amount of lines changed per person: $norm"
cat $out | sort | uniq -c | sort -nr | head -n8
rm $out

