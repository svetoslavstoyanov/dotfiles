#!/usr/bin/env bash

install_antigen() {
  if [[ ! -f "$HOME/.antigen.zsh" ]]; then
    log "Installing Antigen"
    curl -fsSL git.io/antigen >"$HOME/.antigen.zsh"
  else
    warn "Antigen already installed"
  fi
}
