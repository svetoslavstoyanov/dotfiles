#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/bootstrap.sh
source "$SCRIPT_DIR/scripts/bootstrap.sh"

usage() {
  cat <<'EOF'
Usage: ./setup.sh [stage]

Stages:
  update            Update Arch Linux with pacman
  create-user       Create a user and grant wheel sudo access
  install-packages  Install pacman, AUR, and user packages
  link-config       Link files from config/ into ~/.config/
  link-home         Link files from home/ into ~/
  git-config        Configure Git identities, defaults, delta, and hooks

With no stage, run the full setup as root: update, create a user, then run
the personal setup stages as that user. Use --help to show this message.
EOF
}

require_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    error "This stage must run as root. Run it with sudo or from a root shell."
    exit 1
  fi
}

run_update() {
  require_root
  log "Updating system"
  pacman -Syu --noconfirm
}

run_create_user() {
  require_root
  create_sudo_user
}

run_install_packages() {
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    error "Run install-packages as the target user; AUR packages must not be built as root."
    return 1
  fi
  local SUDO=""
  sudo_check SUDO

  install_packages
  setup_locale "$SUDO"
  change_shell_to_zsh "$SUDO"
}

run_link_config() {
  link_dir_content "$SCRIPT_DIR/config" "$HOME/.config"
}

run_link_home() {
  link_dir_content "$SCRIPT_DIR/home" "$HOME"
}

run_git_config() {
  config_git
  config_git_hooks
}

user_home_for() {
  local username="$1" passwd_line home_dir
  passwd_line="$(getent passwd "$username")" || return 1
  IFS=: read -r _ _ _ _ _ home_dir _ <<<"$passwd_line"
  printf '%s' "$home_dir"
}

prepare_user_checkout() {
  local username="$1" user_home="$2" user_repo="$2/dev/personal/dotfiles"

  if runuser -u "$username" -- test -r "$SCRIPT_DIR/setup.sh"; then
    printf '%s' "$SCRIPT_DIR"
    return
  fi

  if [[ -e "$user_repo" ]]; then
    error "The checkout is not readable by $username, and $user_repo already exists."
    error "Make the intended checkout readable by that user, then rerun setup."
    return 1
  fi

  log "Copying the setup checkout to $user_repo for $username" >&2
  install -d -o "$username" -g "$(id -gn "$username")" "$user_home/dev/personal"
  install -d -o "$username" -g "$(id -gn "$username")" "$user_repo"
  if ! tar -C "$SCRIPT_DIR" \
    --exclude='config/herdr/*.log' \
    --exclude='config/herdr/*.sock' \
    --exclude=config/herdr/.plugins.lock \
    --exclude=config/herdr/session.json \
    --exclude=config/herdr/session-snapshots \
    --exclude='config/zsh/rc.d/*.zwc' \
    --exclude=config/tmux/plugins \
    -cf - . | tar -C "$user_repo" -xf -; then
    rm -rf "$user_repo"
    return 1
  fi
  chown -R "$username:$(id -gn "$username")" "$user_repo"
  printf '%s' "$user_repo"
}

run_personal_setup_as() {
  local username="$1" user_home user_repo
  user_home="$(user_home_for "$username")" || {
    error "Could not determine the home directory for $username."
    return 1
  }
  user_repo="$(prepare_user_checkout "$username" "$user_home")" || return 1

  runuser -u "$username" -- env \
    HOME="$user_home" USER="$username" LOGNAME="$username" \
    bash "$user_repo/setup.sh" __personal-setup
}

run_full_setup() {
  require_root
  if [[ "${DOTFILES_SKIP_UPDATE:-0}" == 1 ]]; then
    log "System update already completed by install.sh"
  else
    run_update
  fi
  local username
  create_sudo_user || return 1
  username="$CREATED_USERNAME"
  run_personal_setup_as "$username"
}

run_personal_setup() {
  run_link_config
  run_link_home
  run_install_packages
  run_git_config
}

stage="${1:-all}"
if [[ $# -gt 1 ]]; then
  usage >&2
  exit 2
fi

case "$stage" in
  all) run_full_setup ;;
  update) run_update ;;
  create-user) run_create_user ;;
  install-packages) run_install_packages ;;
  link-config) run_link_config ;;
  link-home) run_link_home ;;
  git-config) run_git_config ;;
  __personal-setup) run_personal_setup ;;
  -h|--help|help) usage ;;
  *) error "Unknown stage: $stage"; usage >&2; exit 2 ;;
esac
