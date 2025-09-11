#!/bin/bash

main() {
  set -ex -o pipefail

  rm -rf /opt
  mkdir /opt
  dnf install -y --enablerepo="google-chrome" alacritty black clang cmake \
    codespell distrobox dnf4 google-chrome-stable \
    fedora-workstation-repositories gcc hyperfine keepassxc libcurl-devel \
    make nvtop python3-tqdm qemu-kvm the_silver_searcher vim python3-flake8 \
    bats httpd-tools ninja meson python3-jinja2 SDL2-devel crun-krun podman \
    shellcheck git-clang-format rocm-core-devel hipblas-devel rocblas-devel \
    rocm-hip-devel vulkan-headers vulkan-loader-devel glslang glslc \
    spirv-tools

  if [ $(uname -m) != "aarch64" ]; then
    dnf install -y wine
  fi

  dnf remove -y nano
}

main "$@"

