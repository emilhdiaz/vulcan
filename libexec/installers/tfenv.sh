#!/usr/bin/env zsh

INSTALLERS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${INSTALLERS_DIR}/../common.sh
source ${INSTALLERS_DIR}/brew.sh

tfenv_install() {
  brew_install_or_upgrade_package tfenv
}

tfenv_install_or_upgrade_version() {
  require_tool tfenv

  local VERSION=${1:-}

  tfenv install "${VERSION}"
  tfenv use "${VERSION}"
}
