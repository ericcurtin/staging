#!/bin/bash

set -e

def=$(systemctl get-default)
if [[ "$def" == *"graphical"* ]]; then
  sudo systemctl set-default multi-user.target
elif [[ "$def" == *"multi-user"* ]]; then
  sudo systemctl set-default graphical.target
fi



