#!/usr/bin/env zsh

SHELL_NAME="$(basename "$SHELL")"

if brew list helm &> /dev/null; then
#  echo "Configuring brew:helm"
  source <(helm completion "$SHELL_NAME")
fi
