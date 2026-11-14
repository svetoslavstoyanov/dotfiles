#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO_DIR/scripts/copy_dir_content.sh"

NO_BACKUP=false

while (( $# > 0 )); do
  case "$1" in
    --no-backup) NO_BACKUP=true ;;
    *)
      echo "Usage: $0 [--no-backup]" >&2
      exit 1
      ;;
  esac
  shift
done

copy_dir_content "$REPO_DIR/config" "$HOME/.config"
copy_dir_content "$REPO_DIR/home" "$HOME"
