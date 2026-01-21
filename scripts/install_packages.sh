#!/usr/bin/env bash

install_packages() {
  local SUDO="$1"
  # --- packages ---
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
    ripgrep \
    fd \
    zoxide \
    openssh \
    tree-sitter-cli \
    starship \
    base-devel \
    lsof \
    jq \
    ncurses

  # --- yay (AUR helper) ---
  if ! command -v yay &>/dev/null; then
    log "Installing yay (AUR helper)"
    rm -rf /tmp/yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
  else
    warn "yay already installed"
  fi

  # --- fnm (Fast Node Manager) ---
  log "Installing fnm"
  yay -S --noconfirm --needed fnm-bin || yay -S --noconfirm --needed fnm

  if command -v fnm &>/dev/null; then
    log "Installing latest Node.js LTS via fnm"
    eval "$(fnm env --shell bash)"
    fnm install --lts
    fnm default lts-latest
  else
    warn "fnm not found after install. Skipping Node LTS install."
  fi

  # --- Oh My Zsh ---
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "Installing Oh My Zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    warn "Oh My Zsh already installed"
  fi

  # --- Antigen ---
  if [[ ! -f "$HOME/.antigen.zsh" ]]; then
    log "Installing Antigen"
    curl -fsSL git.io/antigen >"$HOME/.antigen.zsh"
  else
    warn "Antigen already installed"
  fi

  # --- LazyVim ---
  log "Installing LazyVim (Neovim configuration)"
  NVIM_DIR="$HOME/.config/nvim"
  BACKUP_DIR="$HOME/.config/nvim.bak.$(date +%Y%m%d%H%M%S)"
  if [[ -d "$NVIM_DIR" ]]; then
    warn "Existing Neovim config found. Backing up to $BACKUP_DIR"
    mv "$NVIM_DIR" "$BACKUP_DIR"
  fi
  git clone https://github.com/LazyVim/starter "$NVIM_DIR"
  rm -rf "$NVIM_DIR/.git"

  # --- .NET ---
  log "Installing .NET"
  curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel LTS
}
