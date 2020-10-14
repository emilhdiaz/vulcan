#!/usr/bin/env zsh

if brew list asdf &> /dev/null; then
#  echo "Configuring brew:asdf"
  source "$(brew --prefix asdf)/asdf.sh"
fi


