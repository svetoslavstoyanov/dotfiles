#!/usr/bin/env bash

GIT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/git"

config_git() {
  run_steps "$GIT_DIR" git_
}
