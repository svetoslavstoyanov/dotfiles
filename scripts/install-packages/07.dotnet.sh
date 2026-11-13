#!/usr/bin/env bash

install_dotnet() {
  if command -v dotnet &>/dev/null || [[ -x "$HOME/.dotnet/dotnet" ]]; then
    warn ".NET already installed"
  else
    log "Installing .NET"
    curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel LTS
  fi
}
