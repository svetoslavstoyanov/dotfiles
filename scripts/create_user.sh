#!/usr/bin/env bash

create_sudo_user() {
  local username password confirmation sudoers_dir sudoers_file temp_file
  CREATED_USERNAME=""

  if ! command -v pacman >/dev/null 2>&1; then
    error "pacman was not found; create-user must run on Arch Linux."
    return 1
  fi

  log "Ensuring sudo is installed"
  pacman -S --needed --noconfirm sudo
  getent group wheel >/dev/null 2>&1 || groupadd wheel

  while true; do
    read -r -p "Username to create or add to wheel: " username
    if [[ "$username" != root && "$username" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]] && ((${#username} <= 32)); then
      break
    fi
    warn "Enter a valid Linux username (lowercase letters, digits, _ or -)."
  done

  if id "$username" >/dev/null 2>&1; then
    warn "User $username already exists; keeping its current password."
  else
    while true; do
      read -r -s -p "Password for $username: " password
      printf '\n'
      read -r -s -p "Confirm password: " confirmation
      printf '\n'

      if [[ -z "$password" ]]; then
        warn "Password cannot be empty."
      elif [[ "$password" == *:* ]]; then
        warn "Password cannot contain a colon."
      elif [[ "$password" != "$confirmation" ]]; then
        warn "Passwords do not match."
      else
        break
      fi
    done

    useradd --create-home --groups wheel --shell /bin/bash "$username"
    printf '%s:%s\n' "$username" "$password" | chpasswd
    unset password confirmation
    log "Created user $username"
  fi

  usermod --append --groups wheel "$username"
  sudoers_dir="/etc/sudoers.d"
  sudoers_file="$sudoers_dir/10-wheel"
  install -d -m 0755 "$sudoers_dir"
  if [[ -e "$sudoers_file" ]]; then
    if ! grep -qxF '%wheel ALL=(ALL:ALL) ALL' "$sudoers_file"; then
      error "$sudoers_file exists and does not contain the expected wheel rule; leaving it unchanged."
      return 1
    fi
    visudo -c
  else
    temp_file="$(mktemp "$sudoers_dir/.10-wheel.XXXXXX")"
    printf '%%wheel ALL=(ALL:ALL) ALL\n' >"$temp_file"
    chmod 0440 "$temp_file"
    if ! visudo -c -f "$temp_file"; then
      rm -f "$temp_file"
      return 1
    fi
    mv "$temp_file" "$sudoers_file"
    if ! visudo -c; then
      rm -f "$sudoers_file"
      return 1
    fi
  fi

  log "Granted $username sudo access through wheel"
  CREATED_USERNAME="$username"
}
