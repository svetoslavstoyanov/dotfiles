#!/usr/bin/env bash

pacman_package_installed() {
  pacman -Qq "$1" >/dev/null 2>&1
}

install_aur_package_if_missing() {
  local package="$1"
  if pacman_package_installed "$package"; then
    log "$package is already installed"
  else
    yay -S --noconfirm --needed "$package"
  fi
}

install_packages() {
  local SUDO="$1"

  log "Installing pacman packages"
  $SUDO pacman -S --noconfirm --needed \
    git curl wget zsh bat eza fzf btop ranger xclip zip unzip neovim lazygit \
    git-delta ripgrep fd zoxide openssh tree-sitter-cli starship base-devel \
    lsof jq fx lazydocker ncurses ttf-jetbrains-mono-nerd

  if ! command -v yay >/dev/null 2>&1; then
    log "Installing yay (AUR helper)"
    local yay_dir
    yay_dir="$(mktemp -d "${TMPDIR:-/tmp}/yay.XXXXXX")"
    git clone https://aur.archlinux.org/yay.git "$yay_dir/yay"
    (cd "$yay_dir/yay" && makepkg --syncdeps --install --needed --noconfirm)
    rm -rf "$yay_dir"
  fi

  if ! command -v herdr >/dev/null 2>&1; then
    install_aur_package_if_missing herdr-bin
  fi

  if ! command -v fnm >/dev/null 2>&1 && ! pacman_package_installed fnm-bin && ! pacman_package_installed fnm; then
    log "Installing fnm"
    yay -S --noconfirm --needed fnm-bin || yay -S --noconfirm --needed fnm
  fi
  if command -v fnm >/dev/null 2>&1; then
    if ! fnm list 2>/dev/null | grep -Eq 'v[0-9]+\.[0-9]+' && ! command -v node >/dev/null 2>&1; then
      log "Installing latest Node.js LTS via fnm"
      eval "$(fnm env --shell bash)"
      fnm install --lts
      fnm default lts-latest
    fi
  fi

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "Installing Oh My Zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  if [[ ! -f "$HOME/.antigen.zsh" ]]; then
    log "Installing Antigen"
    curl -fsSL https://git.io/antigen >"$HOME/.antigen.zsh"
  fi

  if [[ ! -e "$HOME/.config/nvim" && ! -L "$HOME/.config/nvim" ]]; then
    log "Installing LazyVim starter configuration"
    mkdir -p "$HOME/.config"
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
  fi

  if ! command -v dotnet >/dev/null 2>&1 && [[ ! -x "$HOME/.dotnet/dotnet" ]]; then
    log "Installing .NET LTS"
    curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel LTS
  fi
}
