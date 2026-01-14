SOURCE_DIR="$HOME/.config/zsh/rc.d"
 autoload -Uz compinit
 compinit

for f in "$SOURCE_DIR"/*.zsh(.N); do
  source "$f" || echo "⚠️  Warning: failed to source $f"
done
