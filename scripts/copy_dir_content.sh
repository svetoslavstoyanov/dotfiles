#!/usr/bin/env bash

copy_file() {
  local src="$1"
  local target="$2"

  if [[ -L "$target" ]]; then
    rm "$target"
  elif [[ -e "$target" ]]; then
    if cmp -s "$src" "$target"; then
      echo "✔ Up to date: $target"
      return
    fi

    if [[ "${OVERWRITE:-false}" == true ]]; then
      if [[ "${NO_BACKUP:-false}" == true ]]; then
        cp -p "$src" "$target"
        echo "⚠️  Overwrote $target (no backup)"
      else
        local backup="$target.bak.$(date +%Y%m%d%H%M%S)"
        mv "$target" "$backup"
        cp -p "$src" "$target"
        echo "⚠️  Overwrote $target (backup: $backup)"
      fi
      return
    fi

    local merged
    merged="$(mktemp "$target.merged.XXXXXX")"
    awk 'NR==FNR { seen[$0] = 1; print; next } !seen[$0]' \
      "$src" "$target" > "$merged"

    if cmp -s "$merged" "$target"; then
      rm -f "$merged"
      echo "✔ Up to date: $target"
      return
    fi

    chmod --reference="$target" "$merged"

    if [[ "${NO_BACKUP:-false}" == true ]]; then
      mv "$merged" "$target"
      echo "⚠️  Merged $target (no backup)"
      return
    fi

    local backup="$target.bak.$(date +%Y%m%d%H%M%S)"
    mv "$target" "$backup"
    mv "$merged" "$target"
    echo "⚠️  Merged $target (backup: $backup)"
    return
  fi

  cp -p "$src" "$target"
  echo "→ Copied $target"
}

copy_dir_content() {
  local src_dir="$1" # e.g. "$CLONE_DIR/config"
  local dst_dir="$2" # e.g. "$HOME/.config"

  mkdir -p "$dst_dir"

  local item name target
  shopt -s nullglob dotglob

  for item in "$src_dir"/*; do
    name="$(basename "$item")"
    target="$dst_dir/$name"

    if [[ -d "$item" && ! -L "$item" ]]; then
      # Replace directory symlinks created by older versions of this script.
      if [[ -L "$target" ]]; then
        echo "⚠️  Replacing old directory symlink: $target"
        rm "$target"
      fi
      copy_dir_content "$item" "$target"
    else
      copy_file "$item" "$target"
    fi
  done

  shopt -u nullglob dotglob
}
