#!/usr/bin/env bash

if ! command -v pipx &> /dev/null; then
  return 0
fi

export PATH="${HOME}/.local/bin:$PATH"

echo "pipx configured!"
