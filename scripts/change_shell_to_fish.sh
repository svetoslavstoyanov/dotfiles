#!/usr/bin/env bash

change_shell_to_fish() {
  FISH_PATH="/usr/bin/fish"
  if [[ "${SHELL:-}" != *fish ]]; then
    log "Setting fish as default shell"
    if [[ -w /etc/shells ]] || $SUDO true 2>/dev/null; then
      if ! grep -qFx "$FISH_PATH" /etc/shells; then
        echo "$FISH_PATH" | $SUDO tee -a /etc/shells >/dev/null
      fi
    fi
    chsh -s "$FISH_PATH" || warn "chsh failed (common on WSL). You can still use fish by running: exec fish"
  fi

  cd
  exec fish

}
