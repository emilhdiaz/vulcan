#!/usr/bin/env bash

TFENV_DIR="$HOME/.tfenv"

[ -d "${TFENV_DIR}/bin" ] && export PATH="${TFENV_DIR}/bin:$PATH"

if ! command -v tfenv &> /dev/null; then
  return 0
fi

echo "tfenv configured!"
