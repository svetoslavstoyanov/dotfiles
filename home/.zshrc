SOURCE_DIR="$HOME/.config/zsh/rc.d"

for f in "$SOURCE_DIR"/*.zsh(.N); do
  source "$f" || echo "⚠️  Warning: failed to source $f"
done
