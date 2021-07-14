#!/usr/bin/env zsh

SILENT=$1
export PIPX_DIR="$HOME/.local"
export PATH="${HOME}/.local/bin:$PATH"

# we're done if no output is desired
[ -n "$SILENT" ] && return 0

# check if command loaded
if ! command -v pipx &> /dev/null; then
  echo "Failed to initialize pipx!" && return 1
else
  echo "Successfully initialized pipx!" && return 0
fi
