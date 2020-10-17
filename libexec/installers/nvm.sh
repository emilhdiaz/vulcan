#!/usr/bin/env zsh

INSTALLERS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${INSTALLERS_DIR}/../common.sh
source ${INSTALLERS_DIR}/brew.sh

nvm_install() {
  brew_install_or_upgrade_package nvm
  mkdir -p "${NVM_DIR}"
}

nvm_install_or_upgrade_version() {
  require_tool nvm

  local VERSION=${1:-}

  nvm install "${VERSION}"
  npm config set user 0
  npm config set unsafe-perm true
  npm install -g npm
}
