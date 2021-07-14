#!/usr/bin/env zsh

SILENT=$1
export ASDF_DIR="$HOME/.asdf"

# installed via homebrew
if brew list asdf &> /dev/null; then
  INSTALL_DIR="$(brew --prefix asdf)"

# installed manually
elif [[ -f "$HOME/.asdf/asdf.sh" ]]; then
  INSTALL_DIR="$HOME/.asdf"

# not installed
else
  return 0
fi

# source the init script
[ -s "$INSTALL_DIR/asdf.sh" ] && source "$INSTALL_DIR/asdf.sh"

# we're done if no output is desired
[ -n "$SILENT" ] && return 0

# check if command loaded
if ! command -v asdf &> /dev/null; then
  echo "Failed to initialize asdf!" && return 1
else
  echo "Successfully initialized asdf!" && return 0
fi
