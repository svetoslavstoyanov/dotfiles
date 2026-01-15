#!/usr/bin/env bash

setup_locale() {
  local SUDO="$1"
  local LOCALE="en_US.UTF-8"
  local LOCALE_GEN="/etc/locale.gen"

  log "Setup locale"

  # Ensure locale is present and uncommented (or add it if missing)
  if grep -qE '^[[:space:]]*#?[[:space:]]*en_US\.UTF-8[[:space:]]+UTF-8' "$LOCALE_GEN"; then
    $SUDO sed -i \
      's/^[[:space:]]*#[[:space:]]*en_US\.UTF-8[[:space:]]\+UTF-8/en_US.UTF-8 UTF-8/' \
      "$LOCALE_GEN"
  else
    echo "en_US.UTF-8 UTF-8" | $SUDO tee -a "$LOCALE_GEN" >/dev/null
  fi

  # Generate locales
  $SUDO locale-gen

  # Set system-wide locale
  if [ ! -f /etc/locale.conf ] || ! grep -q "^LANG=$LOCALE" /etc/locale.conf; then
    echo "LANG=$LOCALE" | $SUDO tee /etc/locale.conf >/dev/null
  fi

  # Apply locale to current script session ONLY if it exists
  if locale -a | grep -qiE '^en_US\.(utf8|UTF-8)$'; then
    export LANG="$LOCALE"
    export LC_ALL="$LOCALE"
  else
    warn "Locale $LOCALE not available yet; skipping LC_ALL export"
  fi
}
