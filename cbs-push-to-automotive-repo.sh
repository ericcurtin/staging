#!/bin/bash

set -ex

cbs-add-pkg() {
  cbs add-pkg --owner=$owner $tag_head-$1 $pkg_name
}

cbs-move() {
  cbs move $tag_head-$1 $tag_head-$2 $pkg_name-$version-$release
}

get_metadata() {
  echo "$build_out" | grep -A1 "^'$1':" | tail -n1 | sed "s/'//g" | sed "s/,//g"
}

owner="ecurtin"
tag_head="automotive9s-packages-main"
gitlab_auto="https://gitlab.com/centos/automotive/rpms"
pkg_name=$(basename $PWD)
commit=$(git rev-parse HEAD)
cbs-add-pkg "candidate"
cbs-add-pkg "testing"
cbs-add-pkg "release"

set +e

cbs build $tag_head-el9s git+$gitlab_auto/$pkg_name.git#$commit
build_out=$(cbs build $tag_head-el9s git+$gitlab_auto/$pkg_name.git#$commit)

set -e

echo $build_out
build_out=$(echo "$build_out" | sed 's/\s\+/\n/g')
version=$(get_metadata "version")
release=$(get_metadata "release")
cbs-move "candidate" "testing"
cbs-move "testing" "release"

