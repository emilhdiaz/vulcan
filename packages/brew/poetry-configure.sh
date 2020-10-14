#!/usr/bin/env zsh

if brew list poetry &> /dev/null; then
#  echo "Configuring brew:poetry"
  export POETRY_HOME="$HOME/.poetry"
  export PATH="${POETRY_HOME}/bin:$PATH"
fi
