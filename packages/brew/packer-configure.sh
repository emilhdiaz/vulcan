#!/usr/bin/env zsh

if brew list packer &> /dev/null; then
#  echo "Configuring brew:packer"
  complete -o nospace -C /usr/local/bin/packer $PROGRAM
fi
