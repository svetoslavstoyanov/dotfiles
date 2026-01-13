#!/usr/bin/env bash
set -euo pipefail

source "$CLONE_DIR/scripts/bootstrap.sh"

SUDO=""
sudo_check SUDO

# --- update ---
log "Updating system"
$SUDO pacman -Syu --noconfirm
install_packages "$SUDO"

# --- link dotfile repo ---
LINK_REPO_DIR="$HOME/dev/personal/dotfiles"
TARGET_LINK_REPO_DIR="$HOME/.dotfiles"
link_dir_content "$LINK_REPO_DIR" "$TARGET_LINK_REPO_DIR"

# --- link config dir ---
LINK_CONFIG_DIR="$TARGET_LINK_REPO_DIR/config"
TARGET_LINK_CONFIG_DIR="$HOME/.config"
link_dir_content "$LINK_DIR" "$TARGET_CONFIG"

# --- link home dir ---
LINK_HOME_DIR="$TARGET_LINK_REPO_DIR/home"
TARGET_LINK_HOME_DIR="$HOME"
link_dir_content "$LINK_DIR" "$TARGET_HOME"

change_shell_to_zsh

log "Done 🎉"
echo "Next steps:"
echo "  1) Restart terminal or run: exec zsh"
echo "  2) First LazyVim launch: nvim  (plugins will install)"
echo "  3) fzf keys: Ctrl-R history, Ctrl-T files, Alt-C cd"
