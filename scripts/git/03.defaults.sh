#!/usr/bin/env bash

git_defaults() {
  log "Configuring Git defaults"

  # Automatically configure the upstream when pushing a new branch for the
  # first time, remove stale remote-tracking branches during fetches, and
  # rebase local commits when pulling.
  git config --global push.autoSetupRemote true
  git config --global fetch.prune true
  git config --global pull.rebase true

  echo "✔ Git push, pull, and fetch defaults configured"
}
