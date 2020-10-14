#!/usr/bin/env zsh

INSTALLERS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${INSTALLERS_DIR}/../common.sh
source ${INSTALLERS_DIR}/brew.sh

pyenv_install() {
  brew_install_or_upgrade_package pyenv
  brew_install_or_upgrade_package pyenv-virtualenv
}

pyenv_install_or_upgrade_version() {
  require_tool pyenv

  local VERSION=${1:-}

  pyenv install -v -s "${VERSION}"
  pyenv global "${VERSION}"
  pip3 install --upgrade pip
}
