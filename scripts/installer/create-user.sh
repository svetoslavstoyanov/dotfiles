#!/usr/bin/env sh
#
# Create a password-protected user with wheel (sudo) access.
# Invoked by install.sh, but can also be run standalone as root:
#   sh scripts/installer/create-user.sh [--output FILE]
#
# Prompts always read from /dev/tty so the script can safely be called from a
# context where stdin is not the terminal (e.g. `curl ... | sh`).
set -eu

TTY="/dev/tty"

log() { printf '\033[32m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[33m==> %s\033[0m\n' "$*" >&2; }
die() { printf '\033[31m==> %s\033[0m\n' "$*" >&2; exit 1; }

OUTPUT_FILE=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --output)
      [ "$#" -ge 2 ] || die "--output requires a file path"
      OUTPUT_FILE="$2"
      shift 2
      ;;
    -h|--help)
      printf 'Usage: %s [--output FILE]\n' "$0"
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

[ "$(id -u)" -eq 0 ] || die "This script must run as root."
{ : <"$TTY"; } 2>/dev/null || die "No terminal at $TTY. Run this from a normal console or SSH session."
command -v useradd >/dev/null 2>&1 || die "useradd not found."
command -v visudo >/dev/null 2>&1 || die "visudo not found (install sudo first)."

groupadd -f wheel

user_exists() { id -u "$1" >/dev/null 2>&1; }
valid_username() { printf '%s' "$1" | grep -Eq '^[a-z_][a-z0-9_-]*$'; }

user=""
while :; do
  printf 'Username for the new sudo user: ' >"$TTY"
  IFS= read -r candidate <"$TTY" || die "Failed to read from $TTY."

  [ -n "$candidate" ] || { warn "Username cannot be empty."; continue; }
  if [ "${#candidate}" -gt 32 ] || ! valid_username "$candidate"; then
    warn "Use up to 32 lowercase letters, digits, '_' or '-', starting with a letter or '_'."
    continue
  fi
  if [ "$candidate" = "root" ]; then
    warn "Refusing to reuse the root account; choose another name."
    continue
  fi

  if user_exists "$candidate"; then
    printf 'User %s already exists. Reuse it? [y/N]: ' "$candidate" >"$TTY"
    IFS= read -r reuse <"$TTY" || die "Failed to read from $TTY."
    case "$reuse" in
      y|Y|yes|YES) user="$candidate"; break ;;
      *) warn "Choose a different username."; continue ;;
    esac
  fi

  user="$candidate"
  break
done

if user_exists "$user"; then
  log "Reusing existing user $user"
  if ! id -nG "$user" | tr ' ' '\n' | grep -qx wheel; then
    usermod -aG wheel "$user"
  fi
else
  log "Creating user $user"
  useradd -m -G wheel -s /bin/bash "$user"
  printf 'Set a password for %s.\n' "$user" >"$TTY"
  passwd "$user" <"$TTY" || die "Password setup for $user failed."
fi

SUDOERS_FILE="/etc/sudoers.d/10-wheel"
if [ ! -f "$SUDOERS_FILE" ]; then
  log "Enabling sudo for the wheel group"
  ( umask 077; printf '%%wheel ALL=(ALL:ALL) ALL\n' >"$SUDOERS_FILE" )
  chmod 440 "$SUDOERS_FILE"
  if ! visudo -cf "$SUDOERS_FILE" >/dev/null 2>&1; then
    rm -f "$SUDOERS_FILE"
    die "Generated sudoers file failed validation; removed it."
  fi
else
  warn "$SUDOERS_FILE already exists; leaving it unchanged"
fi

if [ -n "$OUTPUT_FILE" ]; then
  printf '%s\n' "$user" >"$OUTPUT_FILE"
fi

log "User $user can use sudo (wheel)"
