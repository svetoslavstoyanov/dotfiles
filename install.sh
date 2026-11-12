#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/svetoslavstoyanov/dotfiles.git"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  pacman -Syu --needed git
else
  sudo pacman -Syu --needed git
fi

git clone "$REPO_URL" "$WORK_DIR/dotfiles"
# TEMP: remove this checkout after testing the published branch.
git -C "$WORK_DIR/dotfiles" checkout -B optimize-repo origin/optimize-repo

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  DOTFILES_SKIP_UPDATE=1 bash "$WORK_DIR/dotfiles/setup.sh"
else
  sudo env DOTFILES_SKIP_UPDATE=1 bash "$WORK_DIR/dotfiles/setup.sh"
fi
