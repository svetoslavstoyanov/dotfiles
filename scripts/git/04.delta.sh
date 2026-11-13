#!/usr/bin/env bash

git_delta() {
  log "Configuring delta as Git pager"

  if ! command -v delta &>/dev/null; then
    warn "delta not found; skip pager config (install git-delta)"
    return 1
  fi

  git config --global core.pager delta
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.navigate true
  git config --global delta.true-color always
  git config --global delta.line-numbers true
  git config --global delta.dark true
  git config --global delta.syntax-theme "Catppuccin Mocha"
  git config --global delta.hyperlinks true
  git config --global delta.file-decoration-style "blue ul"
  git config --global delta.hunk-header-decoration-style "blue box"
  git config --global delta.side-by-side false
  git config --global diff.colorMoved default
  git config --global merge.conflictstyle zdiff3

  echo "✔ delta configured as Git pager"
}
