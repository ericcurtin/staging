#!/bin/bash

set -e

host="$1"

export GIT_SSH_COMMAND='ssh'
branch="$(git rev-parse --abbrev-ref HEAD)"
base="$(basename $PWD)"
path="~/git/$base/"
$GIT_SSH_COMMAND $host "mkdir -p $path && cd $path && git init && git config receive.denyCurrentBranch ignore"

git push -f $host:$path

if [ "$2" = "clean" ]; then
  $GIT_SSH_COMMAND $host "cd $path && sudo git clean -fdx"
fi

$GIT_SSH_COMMAND $host "cd $path && git reset --hard $branch"

