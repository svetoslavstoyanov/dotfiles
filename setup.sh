#!/usr/bin/env bash
set -euo pipefail

source "./scripts/bootstrap.sh"

SUDO=""
sudo_check SUDO

# --- update ---
log "Updating system"
$SUDO pacman -Syu --noconfirm

# --- link config dir ---
LINK_REPO_DIR="$HOME/dev/personal/dotfiles"
CONFIG="config"
LINK_CONFIG_DIR="$LINK_REPO_DIR/$CONFIG"
TARGET_LINK_CONFIG_DIR="$HOME/.$CONFIG"

link_dir_content "$LINK_CONFIG_DIR" "$TARGET_LINK_CONFIG_DIR"

# --- link home dir ---
LINK_HOME_DIR="$LINK_REPO_DIR/home"
TARGET_LINK_HOME_DIR="$HOME"

link_dir_content "$LINK_HOME_DIR" "$TARGET_LINK_HOME_DIR"

install_packages "$SUDO"

config_tmux
change_shell_to_zsh
