SOURCE_DIR="$HOME/.config/zsh/rc.d"

if [[ -d "$SOURCE_DIR" ]]; then
  for f in "$SOURCE_DIR"/*.zsh(.N); do
    source "$f" || echo "⚠️  Warning: failed to source $f"
  done
fi

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
