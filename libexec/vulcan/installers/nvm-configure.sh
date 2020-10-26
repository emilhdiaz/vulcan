#!/usr/bin/env bash

NVM_DIR="$HOME/.nvm"

# installed via homebrew
if brew list nvm &> /dev/null; then
  INSTALL_DIR="$(brew --prefix nvm)"
  [ -s "$INSTALL_DIR/nvm.sh" ] && source "$INSTALL_DIR/nvm.sh"
  [ -s "$INSTALL_DIR/etc/bash_completion.d/nvm" ] && source "$INSTALL_DIR/etc/bash_completion.d/nvm"

# installed manually
elif [[ -d "$NVM_DIR" ]]; then
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
fi

if ! command -v nvm &> /dev/null; then
  return 0
fi

export NVM_DIR="$NVM_DIR"
mkdir -p "$NVM_DIR"

export PATH="./node_modules/.bin:$PATH"

echo "nvm configured!"