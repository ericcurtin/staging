#!/bin/bash

set -e

host="$1"

branch="$(git rev-parse --abbrev-ref HEAD)"
base="$(basename $PWD)"
path="~/git/$base/"
ssh $host "mkdir -p $path && cd $path && git init && git config receive.denyCurrentBranch ignore"

git push -f $host:$path

if [ "$2" = "clean" ]; then
  ssh $host "cd $path && sudo git clean -fdx"
fi

ssh $host "cd $path && git reset --hard $branch"

