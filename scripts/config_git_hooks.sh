#!/usr/bin/env bash

config_git_hooks() {
  local hooks_dir="$HOME/.config/git/hooks"
  local hook="$hooks_dir/prepare-commit-msg"

  log "Configuring global Git hooks"

  if [[ ! -f "$hook" ]]; then
    warn "Hook not found at $hook (is config/git linked into ~/.config?)"
    return 1
  fi

  chmod +x "$hook"

  local current
  current="$(git config --global --get core.hooksPath 2>/dev/null || true)"

  if [[ "$current" == "$hooks_dir" ]]; then
    echo "✔ core.hooksPath already set to $hooks_dir"
  else
    git config --global core.hooksPath "$hooks_dir"
    echo "→ Set core.hooksPath to $hooks_dir"
  fi
}
