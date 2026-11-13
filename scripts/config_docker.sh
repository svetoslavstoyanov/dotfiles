#!/usr/bin/env bash

config_docker() {
  local SUDO="$1"

  log "Configuring Docker"

  if ! command -v docker &>/dev/null; then
    warn "Docker is not installed; skipping configuration"
    return 0
  fi

  if systemctl is-enabled --quiet docker.service 2>/dev/null; then
    echo "✔ docker.service already enabled"
  elif $SUDO systemctl enable --now docker.service; then
    echo "→ Enabled and started docker.service"
  else
    warn "Could not start docker.service (VPN/bridge conflict?); check: systemctl status docker"
  fi

  local user="${SUDO_USER:-$(id -un)}"
  if [[ "$user" != "root" ]]; then
    if id -nG "$user" | grep -qw docker; then
      echo "✔ $user already in the docker group"
    else
      $SUDO usermod -aG docker "$user"
      warn "Added $user to the docker group; log out and back in to run docker without sudo"
    fi
  fi
}
