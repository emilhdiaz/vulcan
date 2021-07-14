#!/usr/bin/env zsh

SILENT=$1
export TFENV_DIR="$HOME/.tfenv"

# installed via homebrew
if brew list tfenv &> /dev/null; then
  INSTALL_DIR="$(brew --prefix tfenv)"

# installed manually
elif [[ -f "$HOME/.tfenv/bin/tfenv" ]]; then
  INSTALL_DIR="$HOME/.tfenv"
  export PATH="${INSTALL_DIR}/bin:$PATH"

# not installed
else
  return 0
fi

# we're done if no output is desired
[ -n "$SILENT" ] && return 0

# check if command loaded
if ! command -v tfenv &> /dev/null; then
  echo "Failed to initialize tfenv!" && return 1
else
  echo "Successfully initialized tfenv!" && return 0
fi
