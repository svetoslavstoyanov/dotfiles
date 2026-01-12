#!/usr/bin/env bash
set -euo pipefail

# Directory where this script lives
BOOTSTRAP_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Source all other .sh files in this directory (top-level only)
for f in "$BOOTSTRAP_DIR"/*.sh; do
  [[ "$f" == "$BOOTSTRAP_DIR/bootstrap.sh" ]] && continue
  echo "$f"
  source "$f" || echo "⚠️  Warning: failed to source $f"
done
