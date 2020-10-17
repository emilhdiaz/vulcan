#!/usr/bin/env zsh

if brew list pipx &> /dev/null; then
#  echo "Configuring brew:pipx"
  pipx ensurepath > /dev/null 2>&1
fi
