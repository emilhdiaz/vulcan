#!/usr/bin/env bash

PYENV_ROOT="$HOME/.pyenv"

[ -d "${PYENV_ROOT}/bin" ] && export PATH="${PYENV_ROOT}/bin:$PATH"

if ! command -v pyenv &> /dev/null; then
  return 0
fi

export PYENV_ROOT="$HOME/.pyenv"

eval "$(pyenv init -)";
eval "$(pyenv virtualenv-init -)";

echo "pyenv configured!"