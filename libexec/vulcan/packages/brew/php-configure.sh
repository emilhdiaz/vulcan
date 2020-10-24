#!/usr/bin/env zsh

if brew list php &> /dev/null; then
#  echo "Configuring brew:php"
  export PATH="$HOME/.composer/vendor/bin:$PATH"
fi
