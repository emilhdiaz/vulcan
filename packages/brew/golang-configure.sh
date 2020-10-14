#!/usr/bin/env zsh

if brew list golang &> /dev/null; then
#  echo "Configuring brew:golang"
  INSTALL_DIR="$(brew --prefix golang)"
  export GOPATH="${HOME}/.go"
  export GOROOT="$INSTALL_DIR/libexec"
  export PATH="${GOPATH}/bin:${GOROOT}/bin:$PATH"
fi
