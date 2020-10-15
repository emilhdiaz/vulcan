#!/usr/bin/env zsh

SHELL_NAME="$(basename "$SHELL")"

if brew list kubectl &> /dev/null; then
#  echo "Configuring brew:kubectl"
  source <($PROGRAM completion "$SHELL_NAME");
fi
