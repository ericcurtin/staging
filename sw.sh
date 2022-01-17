#!/bin/bash

set -e

if displaymode d | grep '*' | grep -q 1080; then
  displaymode t 3840 2160
else
  displaymode t 1920 1080
fi

