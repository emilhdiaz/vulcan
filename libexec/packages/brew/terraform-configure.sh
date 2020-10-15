#!/usr/bin/env zsh

if brew list terraform &> /dev/null; then
#  echo "Configuring brew:terraform"
  complete -o nospace -C /usr/local/bin/terraform terraform
fi
