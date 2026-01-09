#!/usr/bin/env bash
set -euo pipefail

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"
log() { echo -e "${GREEN}==> $1${RESET}"; }
warn() { echo -e "${YELLOW}==> $1${RESET}"; }
err() { echo -e "${RED}==> $1${RESET}"; }

if [[ $EUID -ne 0 ]]; then
  err "Please run this script as root (or with sudo)."
  exit 1
fi

# --- Ask for username ---
read -rp "Enter new username (e.g. john): " USERNAME
USERNAME="${USERNAME// /}"

if [[ -z "$USERNAME" ]]; then
  err "Username cannot be empty."
  exit 1
fi

if id "$USERNAME" &>/dev/null; then
  warn "User '$USERNAME' already exists. Exiting."
  exit 0
fi

# --- Ask for password (hidden) ---
while true; do
  read -rsp "Enter password for $USERNAME: " PASS1
  echo
  read -rsp "Confirm password: " PASS2
  echo
  if [[ "$PASS1" != "$PASS2" ]]; then
    warn "Passwords do not match. Try again."
    continue
  fi
  if [[ -z "$PASS1" ]]; then
    warn "Password cannot be empty. Try again."
    continue
  fi
  break
done

# --- Ask for sudo/root privileges ---
read -rp "Should this user have root privileges via sudo? [y/N]: " WANT_SUDO
WANT_SUDO="${WANT_SUDO,,}" # lowercase

# --- Create user ---
log "Creating user '$USERNAME'"
useradd -m -s /bin/bash "$USERNAME"

# --- Set password ---
echo "$USERNAME:$PASS1" | chpasswd
log "Password set for '$USERNAME'"

# --- If sudo requested ---
if [[ "$WANT_SUDO" == "y" || "$WANT_SUDO" == "yes" ]]; then
  log "Granting sudo privileges (wheel group)"

  # Install sudo if missing
  if ! command -v sudo &>/dev/null; then
    log "Installing sudo"
    pacman -Sy --noconfirm sudo
  fi

  # Add user to wheel
  usermod -aG wheel "$USERNAME"

  # Enable wheel group in sudoers (safe drop-in)
  # This avoids editing /etc/sudoers directly.
  SUDOERS_DROPIN="/etc/sudoers.d/00-wheel"
  if [[ ! -f "$SUDOERS_DROPIN" ]]; then
    echo "%wheel ALL=(ALL:ALL) ALL" >"$SUDOERS_DROPIN"
    chmod 440 "$SUDOERS_DROPIN"
    log "Created $SUDOERS_DROPIN to enable sudo for wheel group"
  else
    warn "$SUDOERS_DROPIN already exists; leaving as-is"
  fi
else
  log "User will NOT have sudo privileges."
fi

log "Done."

su - "$USERNAME"
