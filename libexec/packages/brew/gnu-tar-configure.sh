#!/usr/bin/env zsh

if brew list gnu-tar &> /dev/null; then
#  echo "Configuring brew:gnu-tar"
  export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
fi
