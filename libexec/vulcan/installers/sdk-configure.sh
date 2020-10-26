#!/usr/bin/env bash

if [[ -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]]; then
  export SDKMAN_DIR="${HOME}/.sdkman"
  source "${HOME}/.sdkman/bin/sdkman-init.sh"
fi
