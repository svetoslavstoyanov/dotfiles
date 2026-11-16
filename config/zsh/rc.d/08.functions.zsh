FUNCTIONS_DIR="${${(%):-%x}:A:h}/functions"

for f in "$FUNCTIONS_DIR"/*.zsh(N-.); do
    source "$f" || echo "⚠️  Warning: failed to source $f"
done
