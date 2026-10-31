#!/usr/bin/env bash

link_dir_content() {
  local src_dir="$1" # e.g. "$REPO_ROOT/config"
  local dst_dir="$2" # e.g. "$HOME/.config"

  mkdir -p "$dst_dir"

  local item name target
  local nullglob_was_set=0 dotglob_was_set=0

  shopt -q nullglob && nullglob_was_set=1
  shopt -q dotglob && dotglob_was_set=1
  shopt -s nullglob dotglob

  for item in "$src_dir"/*; do
    name="$(basename "$item")"
    target="$dst_dir/$name"

    if [[ -L "$target" ]]; then
      if [[ "$(readlink -f -- "$target")" == "$(readlink -f -- "$item")" ]]; then
        echo "✔ Symlink already correct: $target"
      else
        ln -sfn "$item" "$target"
        echo "→ Relinked $target → $item"
      fi
    elif [[ -e "$target" ]]; then
      echo "⚠️  Skipping $target (already exists and is not a symlink)"
    else
      ln -s "$item" "$target"
      echo "→ Linked $target → $item"
    fi
  done

  (( nullglob_was_set )) || shopt -u nullglob
  (( dotglob_was_set )) || shopt -u dotglob
}
