#!/usr/bin/env zsh

if asdf shim-versions poetry &> /dev/null; then
#  echo "Configuring asdf:poetry"
  export POETRY_HOME="$HOME/.asdf/installs/poetry/1.0.10"
  export PATH="${POETRY_HOME}/bin:$PATH"
fi
