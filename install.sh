#!/usr/bin/env sh
#
# Bootstrap installer for a fresh Arch Linux install.
#
# Run as root, inside the installed system:
#   curl -fsSL https://raw.githubusercontent.com/svetoslavstoyanov/dotfiles/master/install.sh | sh
#
# Installs sudo and git, creates a password-protected wheel user (through
# scripts/installer/create-user.sh), then clones this repository and runs
# setup.sh as that user.
set -eu

REPO_URL="https://github.com/svetoslavstoyanov/dotfiles.git"
RAW_BASE="https://raw.githubusercontent.com/svetoslavstoyanov/dotfiles/master"
TTY="/dev/tty"

# --- preflight --------------------------------------------------------------
if [ "$(id -u)" -ne 0 ]; then
  echo "This installer must run as root. Log in as root (e.g. 'su -') and try again." >&2
  exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "pacman not found. This installer targets Arch Linux." >&2
  exit 1
fi

if ! { : <"$TTY"; } 2>/dev/null; then
  echo "No terminal at $TTY. Run this from a normal console or SSH session." >&2
  exit 1
fi

# --- bootstrap packages -----------------------------------------------------
echo "Installing sudo, git and curl"
if ! pacman -Syu --needed --noconfirm sudo git curl; then
  echo "Package installation failed; refreshing archlinux-keyring and retrying" >&2
  pacman -Sy --noconfirm archlinux-keyring
  pacman -Syu --needed --noconfirm sudo git curl
fi

# --- create the sudo user (separate script) ---------------------------------
echo "Creating a user with sudo access"
tmp_script="$(mktemp)"
tmp_user="$(mktemp)"
trap 'rm -f "$tmp_script" "$tmp_user"' 0

curl -fsSL "$RAW_BASE/scripts/installer/create-user.sh" -o "$tmp_script" ||
  { echo "Failed to download scripts/installer/create-user.sh" >&2; exit 1; }

sh "$tmp_script" --output "$tmp_user" <"$TTY"

user="$(cat "$tmp_user")"
[ -n "$user" ] || { echo "User creation did not return a username." >&2; exit 1; }

# --- clone and run setup as the new user ------------------------------------
echo "Cloning the repository and running setup as $user"
su - "$user" -c "
  set -e
  mkdir -p \"\$HOME/dev/personal\"
  git clone $REPO_URL \"\$HOME/dev/personal/dotfiles\"
  cd \"\$HOME/dev/personal/dotfiles\"
  ./setup.sh
" <"$TTY"

echo "Done. User '$user' has sudo access; the repository is at ~/dev/personal/dotfiles"
