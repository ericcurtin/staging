#!/bin/bash

ls_files=$(git diff --name-only --diff-filter=U)

printf "$ls_files" | xargs -I{} git blame {} | awk '/<<<</,/>>>>/' | cut -c-32 | grep -o '..................$' | grep -v "Not Committed Yet" | sort | uniq -c | sort -nr | head -n 8

for i in $(printf "%s\n" $ls_files); do
  printf "\n%s\n" $i
  git blame $i | awk '/<<<</,/>>>>/' | cut -c-32 | grep -o '..................$' | grep -v "Not Committed Yet" | sort | uniq -c | sort -nr | head -n 4 
done

