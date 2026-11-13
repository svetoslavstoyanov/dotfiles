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
  local ssh_key="$4"

  cat >"$path" <<EOF
[user]
  name = $name
  email = $email
[core]
  sshCommand = ssh -i $ssh_key -o IdentitiesOnly=yes
EOF
  echo "→ Wrote $path"
}

generate_ssh_key() {
  local path="$1"
  local email="$2"

  if [[ -f "$path" ]]; then
    echo "✔ SSH key already exists: $path"
    return
  fi

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "$email" -f "$path"
  echo "→ Generated SSH key: $path"
}

git_identity() {
  log "Configuring Git identities"

  local personal_cfg="$HOME/.gitconfig-personal"
  local work_cfg="$HOME/.gitconfig-work"

  if [[ -f "$personal_cfg" || -f "$work_cfg" ]]; then
    warn "Existing Git identity files found"
    read -r -p "Overwrite personal/work Git identities? [y/N]: " overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
      echo "✔ Keeping existing Git identity files"
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

  local personal_key="$HOME/.ssh/id_ed25519_personal"
  local work_key="$HOME/.ssh/id_ed25519_work"

  generate_ssh_key "$personal_key" "$p_email"
  generate_ssh_key "$work_key" "$w_email"

  write_git_identity "$personal_cfg" "$p_first $p_last" "$p_email" "$personal_key"
  write_git_identity "$work_cfg" "$w_first $w_last" "$w_email" "$work_key"
}
