#!/usr/bin/env bash

install_yay() {
  # --- yay (AUR helper) ---
  if ! command -v yay &>/dev/null; then
    log "Installing yay (AUR helper)"
    rm -rf /tmp/yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
  else
    warn "yay already installed"
  fi

  # --- Install herdr ---
  yay -S --noconfirm --needed --answerdiff None --answerclean None herdr-bin

  # --- fnm (Fast Node Manager) ---
  log "Installing fnm"
  yay -S --noconfirm --needed fnm-bin || yay -S --noconfirm --needed fnm
}
