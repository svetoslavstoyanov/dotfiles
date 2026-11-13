#!/usr/bin/env bash

install_yay() {
  # --- yay (AUR helper) ---
  if ! command -v yay &>/dev/null; then
    log "Installing yay (AUR helper)"
    local build_dir
    build_dir="$(mktemp -d)"

    if git clone https://aur.archlinux.org/yay.git "$build_dir" &&
      (cd "$build_dir" && makepkg -si --noconfirm); then
      rm -rf "$build_dir"
    else
      warn "yay build failed (build dir kept at $build_dir)"
      return 1
    fi
  else
    warn "yay already installed"
  fi

  # --- Install herdr ---
  yay -S --noconfirm --needed --answerdiff None --answerclean None herdr-bin

  # --- fnm (Fast Node Manager) ---
  log "Installing fnm"
  yay -S --noconfirm --needed fnm-bin || yay -S --noconfirm --needed fnm
}
