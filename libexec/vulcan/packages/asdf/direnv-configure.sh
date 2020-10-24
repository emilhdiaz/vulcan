#!/usr/bin/env zsh

SHELL_NAME="$(basename "$SHELL")"

if asdf shim-versions direnv &> /dev/null; then
#  echo "Configuring asdf:direnv"
  eval "$(asdf exec direnv hook $SHELL_NAME)"
  #direnv() { asdf exec direnv "$@"; }
fi
