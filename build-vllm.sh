#!/bin/bash

install_deps() {
  if available dnf; then
    dnf install -y git wget ca-certificates gcc gcc-c++ libSM libXext \
      mesa-libGL jq lsof vim numactl
    if is_rhel_based; then
      add_stream_repo "AppStream"
      dnf install -y numactl-devel
      rm_non_ubi_repos

      dnf_install_epel
      dnf install -y gperftools-libs
      rm_non_ubi_repos
    else
      dnf install -y numactl-devel gperftools-libs
    fi

    dnf -y clean all
    rm -rf /var/cache/*dnf*
  elif available apt-get; then
    apt-get update -y
    apt-get install -y --no-install-recommends git curl wget ca-certificates \
      gcc g++ libtcmalloc-minimal4 libnuma-dev ffmpeg libsm6 libxext6 libgl1 \
      jq lsof vim numactl
    rm -rf /var/lib/apt/lists/*
  fi

  rm /root # bootc change
  curl -LsSf https://astral.sh/uv/0.8.17/install.sh | bash
}

add_to_environment() {
  if grep -q "^$1=" /etc/environment; then
    echo "$1 already exists in /etc/environment"
    return 1
  fi

  echo "$1=$2" >> /etc/environment
}

preload_and_ulimit() {
  if [ "$containerfile" = "generic" ]; then
    local ld_preload_file="libtcmalloc_minimal.so.4"
    local ld_preload_file_1="/usr/lib/$uname_m-linux-gnu/$ld_preload_file"
    local ld_preload_file_2="/usr/lib64/$ld_preload_file"
    if [ -e "$ld_preload_file_1" ]; then
      ld_preload_file="$ld_preload_file_1"
    elif [ -e "$ld_preload_file_2" ]; then
      ld_preload_file="$ld_preload_file_2"
    fi

    if [ -e "$ld_preload_file" ]; then
      add_to_environment "LD_PRELOAD" "$ld_preload_file"
    fi
  fi

  echo 'ulimit -c 0' >> ~/.bashrc
  export PATH="/opt/app-root/bin:$virtual_env/bin:/root/.local/bin:$PATH"
  add_to_environment "PATH" "$PATH"
}

pip_install() {
  local url="https://download.pytorch.org/whl"
  if [ "$containerfile" = "generic" ]; then
    url="$url/cpu"
  elif [ "$containerfile" = "cuda" ]; then
    url="$url/cu$(echo "$CUDA_VERSION" | cut -d. -f1,2 | tr -d '.')"
  fi

  uv pip install -v -r "$1" --extra-index-url "$url"
}

pip_install_all() {
  if [ "$containerfile" = "generic" ]; then
    pip_install requirements/cpu-build.txt
    pip_install requirements/cpu.txt
  elif [ "$containerfile" = "cuda" ]; then
    pip_install requirements/build.txt
    pip_install requirements/cuda.txt
  fi
}

set_vllm_env_vars() {
  if [ "$containerfile" = "generic" ]; then
    export VLLM_TARGET_DEVICE="cpu"
    if [ "$uname_m" == "x86_64" ]; then
      export VLLM_CPU_DISABLE_AVX512="0"
      export VLLM_CPU_AVX512BF16="0"
      export VLLM_CPU_AVX512VNNI="0"
    elif [ "$uname_m" == "aarch64" ]; then
      export VLLM_CPU_DISABLE_AVX512="true"
    fi
  elif [ "$containerfile" = "cuda" ]; then
    export VLLM_TARGET_DEVICE="cuda"
  fi
}

main() {
  set -eux -o pipefail

  # shellcheck disable=SC1091
  source lib.sh

  local containerfile=$1
  if [ "$containerfile" != "generic" ] && [ "$containerfile" != "cuda" ]; then
    echo "First argument must be 'generic' or 'cuda'. Got: '$containerfile'"
    return 1
  fi

  local uname_m
  uname_m=$(uname -m)

  install_deps
  local virtual_env="/opt/venv"
  preload_and_ulimit
  uv venv --python 3.11 --seed "$virtual_env"
  uv pip install --upgrade pip

  local vllm_url="https://github.com/vllm-project/vllm"
  local commit="fcfd1eb9c556e295eb5708eb0f5e6ae775807775"
  git_clone_specific_commit "$vllm_url" "$commit"
  set_vllm_env_vars
  pip_install_all

  # Have had to set MAX_JOBS as low as 1 while building, even on machine
  # with 32GB RAM, kept running out of memory causing crashes.
  MAX_JOBS=2 python3 setup.py install

  cd -
  rm -rf vllm /root/.cache
}

main "$@"

