#!/usr/bin/env bash

git_includes() {
  local gitconfig="$HOME/.gitconfig"

  if [[ ! -f "$gitconfig" ]]; then
    cat >"$gitconfig" <<'EOF'
[includeIf "gitdir:~/dev/work/"]
  path = ~/.gitconfig-work
[includeIf "gitdir:~/dev/personal/"]
  path = ~/.gitconfig-personal
EOF
    echo "→ Wrote $gitconfig"
    return
  fi

  if ! grep -q 'gitdir:~/dev/work/' "$gitconfig"; then
    cat >>"$gitconfig" <<'EOF'

[includeIf "gitdir:~/dev/work/"]
  path = ~/.gitconfig-work
EOF
  fi

  if ! grep -q 'gitdir:~/dev/personal/' "$gitconfig"; then
    cat >>"$gitconfig" <<'EOF'

[includeIf "gitdir:~/dev/personal/"]
  path = ~/.gitconfig-personal
EOF
  fi

  echo "✔ $gitconfig includeIf entries present"
}
