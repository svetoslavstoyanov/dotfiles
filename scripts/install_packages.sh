#!/usr/bin/env bash

INSTALL_PACKAGES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/install-packages"

install_packages() {
  run_steps "$INSTALL_PACKAGES_DIR" install_ "$@"
}
