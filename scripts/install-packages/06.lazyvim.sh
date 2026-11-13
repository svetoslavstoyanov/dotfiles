#!/usr/bin/env bash

install_lazyvim() {
  NVIM_DIR="$HOME/.config/nvim"
  if [[ -d "$NVIM_DIR" ]]; then
    warn "Neovim config already exists at $NVIM_DIR; skipping LazyVim install"
  else
    log "Installing LazyVim (Neovim configuration)"
    git clone https://github.com/LazyVim/starter "$NVIM_DIR"
    rm -rf "$NVIM_DIR/.git"
  fi
}
