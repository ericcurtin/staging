#!/bin/bash

git fetch > /dev/null 2>&1 &

if [ -n "$1" ]; then
  this_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

if [ -t 1 ]; then
  bold=$(tput bold)
  norm=$(tput sgr0)
fi

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
}

if ! git merge $1> /dev/null 2>&1; then
  list=$(git diff --name-only --diff-filter=U)
  blame=$(for i in $list; do git blame $i | awk '/<<<</,/>>>>/'; done)
  blame_list_of_commits=$(echo "$blame" | cut -c-8 | sort | uniq | grep -v "00000000")
  for j in $blame_list_of_commits; do
    if [ ! -n "$(git branch $this_branch --contains $j)" ]; then
      that_list="$that_list $j"
    fi
  done

  if [ -n "$that_list" ]; then
    git_fmt="%<(11,trunc)%h %<(16,trunc)%an %<(8,trunc)%ar %<(42,trunc)%s"
    that_log=$(git log --topo-order --branches --pretty=format:"$git_fmt" $that_list | grep "$(echo $that_list | sed 's/ /\\|/g')")
  fi

  printf "%s\n" "$that_log"
fi

