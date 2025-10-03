#!/bin/bash

main() {
  set -ex -o pipefail

  rm -rf /opt
  mkdir /opt
  dnf remove -y docker-cli || true
  dnf install -y alacritty black clang cmake codespell distrobox dnf4 \
    fedora-workstation-repositories gcc hyperfine keepassxc libcurl-devel \
    make nvtop python3-tqdm qemu-kvm the_silver_searcher vim python3-flake8 \
    bats httpd-tools ninja meson python3-jinja2 SDL2-devel crun-krun podman \
    shellcheck git-clang-format vulkan-loader-devel glslang glslc spirv-tools \
    dnf5-plugins golang

  if [ $(uname -m) != "aarch64" ]; then
    dnf install -y --enablerepo="google-chrome" wine google-chrome-stable \
      rocm-core-devel hipblas-devel rocblas-devel rocm-hip-devel
  fi

  dnf remove -y nano
}

main "$@"

