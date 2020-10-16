#!/usr/bin/env zsh

if brew list pyenv &> /dev/null; then
#  echo "Configuring brew:pyenv"
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="${PYENV_ROOT}/bin:$PATH"
  eval "$(pyenv init -)";
  eval "$(pyenv virtualenv-init -)";
fi
