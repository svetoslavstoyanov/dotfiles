SOURCE_DIR="$HOME/.dotfiles/source"

for f in "$SOURCE_DIR"/*.zsh(.N); do
  source "$f" || echo "⚠️  Warning: failed to source $f"
done
