#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$REPO_DIR/scripts/bootstrap.sh"

SUDO=""
sudo_check SUDO

# --- update ---
log "Updating system"
$SUDO pacman -Syu --noconfirm

# --- copy configuration ---
"$REPO_DIR/copy-conf.sh"

install_packages "$SUDO"

setup_locale "$SUDO"

config_git
change_shell_to_zsh
