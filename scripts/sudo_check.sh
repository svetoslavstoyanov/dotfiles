#!/usr/bin/env bash

is_root() { [[ ${EUID:-$(id -u)} -eq 0 ]]; }

sudo_check() {
  local -n sudo_ref=$1
  sudo_ref=""

  if ! is_root; then
    if command -v sudo &>/dev/null; then
      sudo_ref="sudo"
    else
      warn "sudo is not installed and you're not root."
      warn "Either: 1) install sudo first as root: pacman -S sudo"
      warn "or:     2) run this script as root."
      exit 1
    fi
  fi
}
