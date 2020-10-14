#!/usr/bin/env zsh

SHELL_NAME="$(basename "$SHELL")"

if brew list direnv &> /dev/null; then
#  echo "Configuring brew:direnv"
  eval "$(direnv hook $SHELL_NAME)"
fi
