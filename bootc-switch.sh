#!/bin/bash

main() {
  set -exu -o pipefail
  podman build -t bootc -f Containerfile-bootc
  bootc switch --transport containers-storage bootc
}

main "$@"

