#!/usr/bin/env bash
set -euo pipefail

source "./scripts/bootstrap.sh"

SUDO=""
sudo_check SUDO

# --- update ---
log "Updating system"
$SUDO pacman -Syu --noconfirm

# --- copy configuration ---
./copy-conf.sh

install_packages "$SUDO"

setup_locale "$SUDO"

config_git
config_git_hooks
change_shell_to_zsh
