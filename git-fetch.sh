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
base=$(echo "$PWD" | sed "s#$HOME#~#g")
echo $base
path="$base"

git fetch $host:$path
git fetch --tags $host:$path
