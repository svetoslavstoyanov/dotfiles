#!/usr/bin/env bash

prompt_nonempty() {
  local label="$1"
  local default="${2:-}"
  local value=""

  while true; do
    if [[ -n "$default" ]]; then
      read -r -p "$label [$default]: " value
      value="${value:-$default}"
    else
      read -r -p "$label: " value
    fi

    if [[ -n "$value" ]]; then
      printf '%s' "$value"
      return
    fi
    warn "Value cannot be empty"
  done
}

write_git_identity() {
  local path="$1"
  local name="$2"
  local email="$3"

  cat >"$path" <<EOF
[user]
  name = $name
  email = $email
EOF
  echo "→ Wrote $path"
}

ensure_gitconfig_includes() {
  local gitconfig="$HOME/.gitconfig"

  if [[ ! -f "$gitconfig" ]]; then
    cat >"$gitconfig" <<'EOF'
[includeIf "gitdir:~/dev/work/"]
  path = ~/.gitconfig-work
[includeIf "gitdir:~/dev/personal/"]
  path = ~/.gitconfig-personal
EOF
    echo "→ Wrote $gitconfig"
    return
  fi

  if ! grep -q 'gitdir:~/dev/work/' "$gitconfig"; then
    cat >>"$gitconfig" <<'EOF'

[includeIf "gitdir:~/dev/work/"]
  path = ~/.gitconfig-work
EOF
  fi

  if ! grep -q 'gitdir:~/dev/personal/' "$gitconfig"; then
    cat >>"$gitconfig" <<'EOF'

[includeIf "gitdir:~/dev/personal/"]
  path = ~/.gitconfig-personal
EOF
  fi

  echo "✔ $gitconfig includeIf entries present"
}

ensure_git_delta() {
  log "Configuring delta as Git pager"

  if ! command -v delta &>/dev/null; then
    warn "delta not found; skip pager config (install git-delta)"
    return 1
  fi

  git config --global core.pager delta
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.navigate true
  git config --global delta.line-numbers true
  git config --global delta.dark true
  git config --global delta.syntax-theme "Catppuccin Mocha"
  git config --global delta.hyperlinks true
  git config --global delta.file-decoration-style "blue ul"
  git config --global delta.hunk-header-decoration-style "blue box"
  git config --global delta.side-by-side false
  git config --global diff.colorMoved default
  git config --global merge.conflictstyle zdiff3

  echo "✔ delta configured as Git pager"
}

config_git() {
  log "Configuring Git identities"

  local personal_cfg="$HOME/.gitconfig-personal"
  local work_cfg="$HOME/.gitconfig-work"

  if [[ -f "$personal_cfg" || -f "$work_cfg" ]]; then
    warn "Existing Git identity files found"
    read -r -p "Overwrite personal/work Git identities? [y/N]: " overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
      echo "✔ Keeping existing Git identity files"
      ensure_gitconfig_includes
      ensure_git_delta
      return
    fi
  fi

  echo
  echo "Personal Git identity"
  local p_first p_last p_email
  p_first="$(prompt_nonempty "  First name")"
  p_last="$(prompt_nonempty "  Last name")"
  p_email="$(prompt_nonempty "  Email")"

  echo
  echo "Work Git identity"
  local w_first w_last w_email
  w_first="$(prompt_nonempty "  First name" "$p_first")"
  w_last="$(prompt_nonempty "  Last name" "$p_last")"
  w_email="$(prompt_nonempty "  Email")"

  write_git_identity "$personal_cfg" "$p_first $p_last" "$p_email"
  write_git_identity "$work_cfg" "$w_first $w_last" "$w_email"
  ensure_gitconfig_includes
  ensure_git_delta
}
