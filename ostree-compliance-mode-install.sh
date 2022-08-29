#!/bin/bash

set -e

host="mac"

git-push.sh -p8022 ecurtin@$host
ssh -p8022 ecurtin@$host "cd ~/git/ostree-compliance-mode; sudo PREFIX=\"/var\" ./install.sh"

