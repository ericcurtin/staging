#!/bin/bash

set -e


help()
{
   echo "Add description of the script functions here."
   echo
   echo "Syntax: scriptTemplate [-h|p]"
   echo "options:"
   echo "-h    print this help"
   echo "-p    specify non-22 port"
   echo
}

port="22"
while getopts ":hp:" option; do
   case $option in
      h) # display Help
         help
         exit;;
      p) # Enter a name
         port=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

shift $(($OPTIND - 1))
host="$1"

export GIT_SSH_COMMAND="ssh -p$port"
branch="$(git rev-parse --abbrev-ref HEAD)"
base="$(basename $PWD)"
path="~/git/$base/"
$GIT_SSH_COMMAND $host "mkdir -p $path && cd $path && git init && git config receive.denyCurrentBranch ignore"

git push -f $host:$path

if [ "$2" = "clean" ]; then
  $GIT_SSH_COMMAND $host "cd $path && sudo git clean -fdx"
fi

$GIT_SSH_COMMAND $host "cd $path && git reset --hard $branch"

