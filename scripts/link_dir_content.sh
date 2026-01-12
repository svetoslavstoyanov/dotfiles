link_dir_content() {
  local src_dir="$1" # e.g. "$CLONE_DIR/config"
  local dst_dir="$2" # e.g. "$HOME/.config"

  mkdir -p "$dst_dir"
  echo "TEST:"
  echo $src_dir
  echo $dst_dir
  # If no matches, the loop should do nothing (avoid literal '*')
  local item
  shopt -s nullglob
  for item in "$src_dir"/*; do
    local name target
    name="$(basename "$item")"
    target="$dst_dir/$name"

    if [[ -L "$target" ]]; then
      echo "✔ Symlink already exists: $target"
    elif [[ -e "$target" ]]; then
      echo "⚠️  Skipping $target (already exists and is not a symlink)"
    else
      ln -s "$item" "$target"
      echo "→ Linked $target → $item"
    fi
  done
  shopt -u nullglob
}
