#!/usr/bin/env bash

change_shell_to_zsh() {
  local SUDO="${1:-}"
  local ZSH_PATH="/usr/bin/zsh"

  if [[ "${SHELL:-}" != *zsh ]]; then
    log "Setting zsh as default shell"
    if [[ -w /etc/shells ]] || $SUDO true 2>/dev/null; then
      if ! grep -qFx "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | $SUDO tee -a /etc/shells >/dev/null
      fi
    fi
    chsh -s "$ZSH_PATH" || warn "chsh failed (common on WSL). You can still use zsh by running: exec zsh"
  fi

  # Drop into zsh only for interactive runs; setup must return cleanly otherwise.
  if [[ -t 0 && -t 1 ]]; then
    cd "$HOME" || return
    exec zsh
  fi
}
