#!/usr/bin/env bash

link_dir_content() {
  local src_dir="$1" dst_dir="$2" item relative target
  [[ -d "$src_dir" ]] || {
    error "Source directory not found: $src_dir"
    return 1
  }

  mkdir -p "$dst_dir"

  while IFS= read -r -d '' item; do
    [[ "$item" == "$src_dir" ]] && continue
    relative="${item#"$src_dir"/}"
    case "$relative" in
      herdr/session-snapshots|tmux/plugins) continue ;;
    esac
    mkdir -p "$dst_dir/$relative"
  done < <(find "$src_dir" -type d -print0)

  while IFS= read -r -d '' item; do
    relative="${item#"$src_dir"/}"
    case "$relative" in
      herdr/*.log|herdr/.plugins.lock|herdr/session.json|herdr/session-snapshots/*|zsh/rc.d/*.zwc|tmux/plugins/*)
        continue
        ;;
    esac

    target="$dst_dir/$relative"
    if [[ -L "$target" ]]; then
      if [[ "$(readlink "$target")" == "$item" ]]; then
        log "Symlink already exists: $target"
      else
        warn "Skipping $target (already a symlink to another location)"
      fi
    elif [[ -e "$target" ]]; then
      warn "Skipping $target (already exists and is not a symlink)"
    else
      mkdir -p "$(dirname -- "$target")"
      ln -s "$item" "$target"
      log "Linked $target -> $item"
    fi
  done < <(find "$src_dir" -type f -print0)
}
