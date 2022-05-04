#!/bin/bash

set -e

git commit -a --fixup=$1
git rebase --interactive --autosquash $1^

