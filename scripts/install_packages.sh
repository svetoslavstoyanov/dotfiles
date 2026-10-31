#!/usr/bin/env bash

install_zsh_plugin() {
  local repo="$1"
  local name="$2"
  local dest="$ZSH_CUSTOM/plugins/$name"

  if [[ -d "$dest" ]]; then
    warn "$name already installed"
    return 0
  fi

  log "Installing $name"
  git clone --depth 1 "https://github.com/$repo" "$dest"
}

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
    ncurses

  # --- yay (AUR helper) ---
  if ! command -v yay &>/dev/null; then
    log "Installing yay (AUR helper)"
    local yay_dir
    yay_dir="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/yay.git "$yay_dir"
    if ! (cd "$yay_dir" && makepkg -si --noconfirm); then
      rm -rf "$yay_dir"
      return 1
    fi
    rm -rf "$yay_dir"
  else
    warn "yay already installed"
  fi

  # --- Install herdr ---
  yay -S --noconfirm --needed --answerdiff None --answerclean None herdr-bin

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

  # --- Oh My Zsh plugins ---
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  install_zsh_plugin zsh-users/zsh-completions zsh-completions
  install_zsh_plugin zsh-users/zsh-autosuggestions zsh-autosuggestions
  install_zsh_plugin zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting

  # --- LazyVim ---
  local NVIM_DIR="$HOME/.config/nvim"
  if [[ -d "$NVIM_DIR" ]]; then
    warn "Neovim config already exists at $NVIM_DIR; skipping LazyVim install"
  else
    log "Installing LazyVim (Neovim configuration)"
    git clone --depth 1 https://github.com/LazyVim/starter "$NVIM_DIR"
    rm -rf "$NVIM_DIR/.git"
  fi

  # --- .NET ---
  if [[ -x "$HOME/.dotnet/dotnet" ]] || command -v dotnet &>/dev/null; then
    warn ".NET already installed"
  else
    log "Installing .NET"
    curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel LTS
  fi
}
