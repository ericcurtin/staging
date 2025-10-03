#!/bin/bash

ls_images() {
  local sudo=$1
  $sudo podman image ls -a
}

rm_images() {
  local sudo=$1
  xargs -r "$sudo" podman rmi -f > /dev/null 2>&1
}

filter_for_none() {
  grep '<none>' | awk '{print $3}'
}

podman_load() {
  podman -c podman-machine-default-root load
}

main() {
  set -exu -o pipefail

  if [ "$EUID" -eq 0 ]; then
    echo "Please run as rootless"
    return 1
  fi

  # --no-cache, --network host fixes bug
  if sudo bootc status | grep -q machine-os; then
    sudo podman build -t bootc -f Containerfile-bootc-podman-machine
  else
    sudo podman build -t bootc -f Containerfile-bootc
  fi

  ls_images "sudo" | filter_for_none | rm_images "sudo" &
  ls_images "" | filter_for_none | rm_images "" &
  sudo bootc usr-overlay || true
  sudo chcon --reference /usr/bin/rpm-ostree /usr/bin/bootc
  local image_name="localhost/bootc"
  local id
  id="$(sudo podman images -q $image_name)"
  # sudo podman save localhost/bootc | podman_load > /dev/null 2>&1 &
  # sudo podman save "$id" | podman load > /dev/null 2>&1 &
  sudo bootc switch --transport containers-storage "$id"
  wait
  # podman tag "$id" "$image_name"
}

main "$@"

