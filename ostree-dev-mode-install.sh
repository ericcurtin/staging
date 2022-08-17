#!/bin/bash

set -e

git-push.sh -p8022 ecurtin@m1
ssh -p8022 ecurtin@m1 "cd ~/git/ostree-developer-mode; sudo ./install.sh"

