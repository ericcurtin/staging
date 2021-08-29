#!/bin/bash

for file in *; do
  mv "$file" "$(echo $file | sed "s/ /_/g")" > /dev/null 2>&1
done

