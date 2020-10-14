#!/usr/bin/env zsh

if brew list nvm &> /dev/null; then
#  echo "Configuring brew:nvm"
  INSTALL_DIR="$(brew --prefix nvm)"
  export NVM_DIR="$HOME/.nvm"
  export PATH="./node_modules/.bin:$PATH" # for quick access to node packages
  source "$INSTALL_DIR/nvm.sh"
  source "$INSTALL_DIR/etc/bash_completion.d/nvm"
fi
