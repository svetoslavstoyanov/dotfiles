#!/usr/bin/env bash

install_pacman() {
  local SUDO="$1"

  log "Installing pacman packages"
  $SUDO pacman -S --noconfirm --needed \
    git curl wget \
    zsh \
    bat eza fzf \
    btop \
    ranger \
    xclip \
    zip \
    unzip \
    neovim \
    lazygit \
    git-delta \
    ripgrep \
    fd \
    zoxide \
    openssh \
    tree-sitter-cli \
    starship \
    base-devel \
    lsof \
    jq \
    fx \
    lazydocker \
    ncurses \
    ttf-jetbrains-mono-nerd
}
