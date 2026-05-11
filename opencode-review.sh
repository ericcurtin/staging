#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILE="$SCRIPT_DIR/opencode-review-prompt.txt"

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "Error: $PROMPT_FILE not found" >&2
  exit 1
fi

prompt="$(cat "$PROMPT_FILE")"

exec opencode run \
  --dangerously-skip-permissions \
  "$prompt"

