#!/usr/bin/env bash

install_antidote() {
  if [[ ! -d "$HOME/.antidote" ]]; then
    log "Installing antidote"
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
  else
    warn "Antidote already installed"
  fi
}
