#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/bootstrap.sh
source "$REPO_ROOT/scripts/bootstrap.sh"

SUDO=""
sudo_check SUDO

# --- update ---
log "Updating system"
$SUDO pacman -Syu --noconfirm

# --- link config dir ---
link_dir_content "$REPO_ROOT/config" "$HOME/.config"

# --- link home dir ---
link_dir_content "$REPO_ROOT/home" "$HOME"

install_packages "$SUDO"

setup_locale "$SUDO"

config_git
config_git_hooks
change_shell_to_zsh "$SUDO"
