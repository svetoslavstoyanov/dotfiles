#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

collect_backups() {
  local src_dir="$1"
  local dst_dir="$2"
  local item name target backup

  shopt -s nullglob dotglob

  for item in "$src_dir"/*; do
    name="$(basename "$item")"
    target="$dst_dir/$name"

    if [[ -d "$item" && ! -L "$item" ]]; then
      collect_backups "$item" "$target"
    else
      for backup in "$target".bak.*; do
        [[ "$backup" =~ \.bak\.[0-9]{14}([0-9]{3})?$ ]] || continue
        [[ -f "$backup" ]] && printf '%s\0' "$backup"
      done
    fi
  done

  shopt -u nullglob dotglob
}

mapfile -d '' -t backups < <(
  collect_backups "$REPO_DIR/config" "$HOME/.config"
  collect_backups "$REPO_DIR/home" "$HOME"
)

if (( ${#backups[@]} == 0 )); then
  echo "✔ No backups found"
  exit 0
fi

printf '%s\n' "${backups[@]}"

if [[ "${1:-}" != "--yes" ]]; then
  read -r -p "Delete ${#backups[@]} backup(s)? [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]] || { echo "Aborted"; exit 0; }
fi

rm -f -- "${backups[@]}"
echo "✔ Deleted ${#backups[@]} backup(s)"
