#!/bin/bash

set -e

cbs-add-pkg() {
  cbs add-pkg --owner=$owner $tag_head-$1 $pkg_name
}

cbs-move() {
  cbs move $tag_head-$1 $tag_head-$2 $pkg_name-$version-$release
}

owner="ecurtin"
tag_head="automotive9s-packages-main"
gitlab_automotive="https://gitlab.com/centos/automotive/rpms"
pkg_name=$(basename $PWD)
commit=$(git rev-parse HEAD)
cbs-add-pkg "candidate" &
cbs-add-pkg "testing" &
cbs-add-pkg "release" &

build_out=$(cbs build $tag_head-el9s git+$gitlab_automotive/$pkg_name.git#$commit)
build_out=$(echo "$build_out" | sed 's/\s\+/\n/g')
version=$(echo "$build_out" | grep -A1 "^'version':" | tail -n1 | sed "s/'//g" | sed "s/,//g")
release=$(echo "$build_out" | grep -A1 "^'release':" | tail -n1 | sed "s/'//g" | sed "s/,//g")
cbs-move "candidate" "testing"

