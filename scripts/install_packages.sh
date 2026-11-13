#!/usr/bin/env bash

INSTALL_PACKAGES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/install-packages"

install_packages() {
  local SUDO="$1" file name step

  shopt -s nullglob
  for file in "$INSTALL_PACKAGES_DIR"/*.sh; do
    name="${file##*/}"

    if [[ ! "$name" =~ ^[0-9][0-9]\.([A-Za-z0-9_]+)\.sh$ ]]; then
      warn "Skipping $name (expected NN.<name>.sh)"
      continue
    fi

    step="install_${BASH_REMATCH[1]}"
    source "$file"

    if ! declare -F "$step" &>/dev/null; then
      warn "Skipping $name (function $step not defined)"
      continue
    fi

    "$step" "$SUDO"
  done
  shopt -u nullglob
}
