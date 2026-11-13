#!/usr/bin/env bash

GIT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/git"

config_git() {
  local file name step

  shopt -s nullglob
  for file in "$GIT_DIR"/*.sh; do
    name="${file##*/}"

    if [[ ! "$name" =~ ^[0-9][0-9]\.([A-Za-z0-9_]+)\.sh$ ]]; then
      warn "Skipping $name (expected NN.<name>.sh)"
      continue
    fi

    step="git_${BASH_REMATCH[1]}"
    source "$file"

    if ! declare -F "$step" &>/dev/null; then
      warn "Skipping $name (function $step not defined)"
      continue
    fi

    "$step"
  done
  shopt -u nullglob
}
