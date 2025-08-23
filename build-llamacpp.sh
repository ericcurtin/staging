#!/bin/bash

main() {
  set -ex -o pipefail

  git init llama.cpp
  cd llama.cpp
  git remote add origin https://github.com/ggml-org/llama.cpp

  local commit="3ea913f1ce9567289aedd866a569dbab8fb8e419"
  git fetch --depth 1 origin $commit
  git reset --hard $commit
  git submodule update --init --recursive
  cmake -B build -DGGML_CCACHE=OFF -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_HIP_COMPILER_ROCM_ROOT=/usr -DGGML_HIP=ON
  cmake --build build --config Release -j"$(nproc)"
  cmake --install build
}

main "$@"

