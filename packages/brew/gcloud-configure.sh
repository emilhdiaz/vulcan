#!/usr/bin/env zsh

SHELL_NAME="$(basename "$SHELL")"

if brew list --cask google-cloud-sdk &> /dev/null; then
#  echo "Configuring brew:gcloud"
  INSTALL_DIR="$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
  source "$INSTALL_DIR/path.$SHELL_NAME.inc"
  source "$INSTALL_DIR/completion.$SHELL_NAME.inc"
fi
