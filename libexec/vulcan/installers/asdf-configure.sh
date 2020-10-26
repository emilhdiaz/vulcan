#!/usr/bin/env bash

ASDF_DIR="$HOME/.asdf"

# installed via homebrew
if brew list asdf &> /dev/null; then
  source "$(brew --prefix asdf)/asdf.sh"

# installed manually
elif [[ -f "$ASDF_DIR/asdf.sh" ]]; then
  source "$ASDF_DIR/asdf.sh"
fi

if ! command -v asdf &> /dev/null; then
  return 0
fi

echo "asdf configured!"
