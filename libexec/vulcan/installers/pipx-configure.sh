#!/usr/bin/env zsh

if brew list pipx &> /dev/null; then
#  echo "Configuring brew:pipx"
  export PATH="${HOME}/.local/bin:$PATH"
fi
