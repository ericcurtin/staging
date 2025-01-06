#!/bin/bash

main() {
  set -exu -o pipefail

  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    return 1
  fi

  podman build -t bootc -f Containerfile-bootc
  bootc switch --transport containers-storage localhost/bootc
}

main "$@"

