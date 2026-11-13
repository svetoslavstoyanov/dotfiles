#!/usr/bin/env bash

install_node_lts() {
  if command -v fnm &>/dev/null; then
    eval "$(fnm env --shell bash)"
    if fnm list | grep -q 'lts-latest'; then
      warn "Node.js LTS already installed"
    else
      log "Installing latest Node.js LTS via fnm"
      fnm install --lts
      fnm default lts-latest
    fi
  else
    warn "fnm not found after install. Skipping Node LTS install."
  fi
}
