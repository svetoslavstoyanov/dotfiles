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
  ssh \
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

append_once() {
  local marker="$1"
  local content="$2"
  if grep -qF "$marker" "$ZSHRC"; then
    warn "Found '$marker' in .zshrc; skipping append."
  else
    printf "\n%s\n" "$content" >>"$ZSHRC"
  fi
}

append_once "# --- fzf ---" "$(
  cat <<'EOF'
# --- fzf ---
if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
fi
if [[ -f /usr/share/fzf/completion.zsh ]]; then
  source /usr/share/fzf/completion.zsh
fi

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} | head -500'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
EOF
)"

append_once "# --- fnm ---" "$(
  cat <<'EOF'
# --- fnm ---
eval "$(fnm env)"
EOF
)"

append_once "# --- starship ---" "$(
  cat <<'EOF'
# --- starship ---
eval "$(starship init zsh)"
EOF
)"

append_once "# --- antigen ---" "$(
  cat <<'EOF'
# --- antigen ---
source ~/.antigen.zsh
antigen use oh-my-zsh
antigen bundle git
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting
antigen apply
EOF
)"

append_once "# --- aliases ---" "$(
  cat <<'EOF'
# --- aliases ---
alias ls="eza --icons"
alias cat="bat"
EOF
)"

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

log "Done 🎉"
echo "Next steps:"
echo "  1) Restart terminal or run: exec zsh"
echo "  2) First LazyVim launch: nvim  (plugins will install)"
echo "  3) fzf keys: Ctrl-R history, Ctrl-T files, Alt-C cd"

### --- Clone repo + symlink ---
REPO_URL="git@github.com:svetoslavstoyanov/dotfiles.git"
CLONE_DIR="$HOME/dev/personal/dotfiles"
SYMLINK_PATH="$HOME/.dotifles"

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

log "Creating symlink: $SYMLINK_PATH → $CLONE_DIR"

# If symlink exists but points somewhere else, replace it
if [[ -L "$SYMLINK_PATH" ]]; then
  if [[ "$(readlink "$SYMLINK_PATH")" != "$CLONE_DIR" ]]; then
    warn "Symlink exists but points elsewhere. Replacing."
    rm "$SYMLINK_PATH"
    ln -s "$CLONE_DIR" "$SYMLINK_PATH"
  else
    log "Symlink already correct"
  fi
elif [[ -e "$SYMLINK_PATH" ]]; then
  warn "$SYMLINK_PATH exists and is not a symlink. Skipping (safety)."
else
  ln -s "$CLONE_DIR" "$SYMLINK_PATH"
fi
