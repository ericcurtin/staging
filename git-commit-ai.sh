#!/bin/bash

set -eux -o pipefail

main() {
  local model_dir="/Users/ecurtin/.local/share/ramalama/models/ollama/"
  local msg="Write a git commit message (subject and body) for this change, only respond with the git commit message:"
  local res
  res="$(git diff HEAD~ | llama-run "$model_dir/llama3.1:8b" "$msg" || true)"
  git commit -m "$res" "$@"
  git commit --amend "$@"
}

main "$@"

