set -l SOURCE_DIR "$HOME/.config/fish/rc.d"

for f in "$SOURCE_DIR"/*.fish
    source "$f" || echo "⚠️  Warning: failed to source $f"
end