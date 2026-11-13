#!/usr/bin/env bash

# Run every NN.<name>.sh step in a directory, calling <prefix><name> with any
# extra arguments. Malformed files and files without the function are skipped.
run_steps() {
  local dir="$1"
  local prefix="$2"
  shift 2

  local file name step

  shopt -s nullglob
  for file in "$dir"/*.sh; do
    name="${file##*/}"

    if [[ ! "$name" =~ ^[0-9][0-9]\.([A-Za-z0-9_]+)\.sh$ ]]; then
      warn "Skipping $name (expected NN.<name>.sh)"
      continue
    fi

    step="${prefix}${BASH_REMATCH[1]}"
    source "$file"

    if ! declare -F "$step" &>/dev/null; then
      warn "Skipping $name (function $step not defined)"
      continue
    fi

    "$step" "$@"
  done
  shopt -u nullglob
}
