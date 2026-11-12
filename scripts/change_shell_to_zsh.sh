#!/usr/bin/env bash

change_shell_to_zsh() {
  local SUDO="$1" zsh_path="/usr/bin/zsh" username="${USER:-$(id -un)}"
  local current_shell

  current_shell="$(getent passwd "$username" | cut -d: -f7)"
  [[ "$current_shell" == "$zsh_path" ]] && return

  log "Setting zsh as the default shell for $username"
  if ! grep -qFx "$zsh_path" /etc/shells; then
    echo "$zsh_path" | $SUDO tee -a /etc/shells >/dev/null
  fi
  $SUDO chsh -s "$zsh_path" "$username" || warn "Could not change the default shell"
}
