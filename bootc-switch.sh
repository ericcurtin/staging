#!/bin/bash

main() {
  set -exu -o pipefail

  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    return 1
  fi

  podman build -t bootc -f Containerfile-bootc
  bootc usr-overlay
  chcon --reference /usr/bin/rpm-ostree /usr/bin/bootc
  bootc switch --transport containers-storage localhost/bootc
}

main "$@"

