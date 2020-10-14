#!/usr/bin/env zsh

SHELL_NAME="$(basename "$SHELL")"

if asdf shim-versions java &> /dev/null; then
#  echo "Configuring asdf:java"
  source "$HOME/.asdf/plugins/java/set-java-home.$SHELL_NAME"
fi
