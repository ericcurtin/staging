#!/bin/bash

main() {
  set -ex -o pipefail

  git init llama.cpp
  cd llama.cpp
  git remote add origin https://github.com/ggml-org/llama.cpp

  local commit="a68d9144262f1d0ef4f6ba7ad4a7e73e977ba78c"
  git fetch --depth 1 origin $commit
  git reset --hard $commit
  git submodule update --init --recursive
  cmake -B build -DGGML_CCACHE=OFF -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_HIP_COMPILER_ROCM_ROOT=/usr -DGGML_HIP=ON -DGGML_VULKAN=ON
  cmake --build build --config Release -j"$(nproc)"
  cmake --install build
}

main "$@"

