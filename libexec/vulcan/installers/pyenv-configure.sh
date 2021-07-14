#!/usr/bin/env zsh

SILENT=$1
export PYENV_ROOT="$HOME/.pyenv/"

# installed via homebrew
if brew list pyenv &> /dev/null; then
  INSTALL_DIR="$(brew --prefix pyenv)"

# installed manually
elif [[ -f "$HOME/.pyenv/bin/pyenv" ]]; then
  INSTALL_DIR="$HOME/.pyenv"
  export PATH="${INSTALL_DIR}/bin:$PATH"

# not installed
else
  return 0
fi

eval "$(pyenv init --path)"
eval "$(pyenv init -)";
eval "$(pyenv virtualenv-init -)";

# we're done if no output is desired
[ -n "$SILENT" ] && return 0

# check if command loaded
if ! command -v pyenv &> /dev/null; then
  echo "Failed to initialize pyenv!" && return 1
else
  echo "Successfully initialized pyenv!" && return 0
fi
