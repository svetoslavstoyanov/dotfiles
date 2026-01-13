#!/usr/bin/env bash

source './log.sh'

change_shell_to_zsh() {
  ZSH_PATH="/usr/bin/zsh"
  if [[ "${SHELL:-}" != *zsh ]]; then
    log "Setting zsh as default shell"
    if [[ -w /etc/shells ]] || $SUDO true 2>/dev/null; then
      if ! grep -qFx "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | $SUDO tee -a /etc/shells >/dev/null
      fi
    fi
    chsh -s "$ZSH_PATH" || warn "chsh failed (common on WSL). You can still use zsh by running: exec zsh"
  fi
}
