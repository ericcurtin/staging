#!/bin/bash

for l in $(sudo v4l2-ctl --list-devices | grep /); do
  echo "Device File: $l"
  sudo v4l2-ctl --device=$l --all --list-formats-ext
  echo
done

