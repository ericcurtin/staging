#!/bin/bash

ls_images() {
  local sudo=$1
  $sudo $conman image ls -a
}

rm_images() {
  local sudo=$1
  xargs -r "$sudo" $conman rmi -f > /dev/null 2>&1
}

filter_for_none() {
  grep '<none>' | awk '{print $3}'
}

conman_load() {
  $conman -c podman-machine-default-root load
}

main() {
  set -exu -o pipefail

  if [ "$EUID" -eq 0 ]; then
    echo "Please run as rootless"
    return 1
  fi

  local conman="docker"
  local sudo_cmd="sudo"
  if [ $conman = "docker" ]; then
    sudo_cmd=""
  fi

  # --no-cache, --network host fixes bug
  if sudo bootc status | grep -q machine-os; then
    $sudo_cmd $conman build -t bootc -f Containerfile-bootc-$conman-machine .
  else
    $sudo_cmd $conman build -t bootc -f Containerfile-bootc .
  fi

  ls_images "sudo" | filter_for_none | rm_images "sudo" &
  ls_images "" | filter_for_none | rm_images "" &
  sudo bootc usr-overlay || true
  sudo chcon --reference /usr/bin/rpm-ostree /usr/bin/bootc
  local image_name="localhost/bootc"
  local id
  id="$($sudo_cmd $conman images -q $image_name)"
  # sudo $conman save localhost/bootc | $conman_load > /dev/null 2>&1 &
  # sudo $conman save "$id" | $conman load > /dev/null 2>&1 &
  sudo bootc switch --transport containers-storage "$id"
  wait
  # $conman tag "$id" "$image_name"
}

main "$@"

