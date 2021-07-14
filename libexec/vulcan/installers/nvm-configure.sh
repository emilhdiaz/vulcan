#!/usr/bin/env zsh

SILENT=$1
export NVM_DIR="$HOME/.nvm"

# installed via homebrew
if brew list nvm &> /dev/null; then
  INSTALL_DIR="$(brew --prefix nvm)"

# installed manually
elif [[ -f "$HOME/.nvm/nvm.sh" ]]; then
  INSTALL_DIR="$HOME/.nvm"

# not installed
else
  return 0
fi

# source the init script
[ -s "$INSTALL_DIR/nvm.sh" ] && source "$INSTALL_DIR/nvm.sh"

# we're done if no output is desired
[ -n "$SILENT" ] && return 0

# check if command loaded
if ! command -v nvm &> /dev/null; then
  echo "Failed to initialize nvm!" && return 1
else
  echo "Successfully initialized nvm!" && return 0
fi
