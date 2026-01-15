#!/usr/bin/env bash

config_tmux() {

  TPM_DIR="$HOME/.config/tmux/plugins/tpm"

  if [ -d "$TPM_DIR/.git" ]; then
    echo "TPM already installed: $TPM_DIR"
    git -C "$TPM_DIR" pull --ff-only
  elif [ -d "$TPM_DIR" ]; then
    echo "TPM dir exists but is not a git repo: $TPM_DIR (skipping)" >&2
  else
    mkdir -p ~/.config/tmux/plugins
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  fi

}
