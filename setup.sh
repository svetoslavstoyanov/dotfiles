#!/usr/bin/env bash
set -euo pipefail

GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"
log() { echo -e "${GREEN}==> $1${RESET}"; }
warn() { echo -e "${YELLOW}==> $1${RESET}"; }

is_root() { [[ ${EUID:-$(id -u)} -eq 0 ]]; }

# Use sudo only when not root
SUDO=""
if ! is_root; then
  if command -v sudo &>/dev/null; then
    SUDO="sudo"
  else
    warn "sudo is not installed and you're not root."
    warn "Either: 1) install sudo first as root: pacman -S sudo"
    warn "or:     2) run this script as root."
    exit 1
  fi
fi

# --- update ---
log "Updating system"
$SUDO pacman -Syu --noconfirm

# --- packages ---
log "Installing pacman packages"
$SUDO pacman -S --noconfirm --needed \
  git curl wget \
  zsh \
  bat eza fzf \
  btop \
  ranger \
  xclip \
  neovim \
  lazygit \
  ripgrep \
  fd \
  openssh \
  tree-sitter-cli \
  starship \
  base-devel

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

# --- zsh config ---
log "Updating ~/.zshrc (append if missing)"
ZSHRC="$HOME/.zshrc"
touch "$ZSHRC"

# --- default shell ---
ZSH_PATH="/usr/bin/zsh"
if [[ "${SHELL:-}" != *zsh ]]; then
  log "Setting zsh as default shell"
  if [[ -w /etc/shells ]] || $SUDO true 2>/dev/null; then
    if ! grep -qFx "$ZSH_PATH" /etc/shells; then
      echo "$ZSH_PATH" | $SUDO tee -a /etc/shells >/dev/null
    fi
  fi
  chsh -s "$ZSH_PATH" || warn "chsh failed (common on WSL). You can still use zsh by running: exec zsh"
fi

### --- Clone repo + symlink ---
REPO_URL="https://github.com/svetoslavstoyanov/dotfiles.git"
CLONE_DIR="$HOME/dev/personal/dotfiles"

log "Setting up repository: $REPO_URL"

# Ensure parent dir exists
mkdir -p "$(dirname "$CLONE_DIR")"

if [[ -d "$CLONE_DIR/.git" ]]; then
  log "Repository already exists. Pulling latest changes."
  git -C "$CLONE_DIR" pull --ff-only || warn "Could not pull updates"
elif [[ -d "$CLONE_DIR" ]]; then
  warn "$CLONE_DIR exists but is not a git repo. Skipping clone."
else
  log "Cloning repository"
  git clone "$REPO_URL" "$CLONE_DIR"
fi

source "$CLONE_DIR/scripts/bootstrap.sh"

DOTFILES_CONFIG="$CLONE_DIR/config"
DOTFILES_HOME="$HOME/home"
TARGET_CONFIG="$HOME/.config"
TARGET_HOME="$HOME"

link_dir_content "$DOTFILES_CONFIG" "$TARGET_CONFIG"
link_dir_content "$DOTFILES_HOME" "$TARGET_HOME"

log "Done 🎉"
echo "Next steps:"
echo "  1) Restart terminal or run: exec zsh"
echo "  2) First LazyVim launch: nvim  (plugins will install)"
echo "  3) fzf keys: Ctrl-R history, Ctrl-T files, Alt-C cd"
