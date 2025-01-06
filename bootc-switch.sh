#!/bin/bash

main() {
  set -exu -o pipefail

  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    return 1
  fi

  podman build -t bootc -f Containerfile-bootc
  bootc usr-overlay || true
  chcon --reference /usr/bin/rpm-ostree /usr/bin/bootc
  local id="$(podman images -q localhost/bootc)"
  bootc switch --transport containers-storage "$id"
}

main "$@"

