#!/usr/bin/env zsh

if brew list --cask java &> /dev/null; then
#  echo "Configuring brew:java"
  export JAVA_HOME="$(/usr/libexec/java_home -V)"
fi
