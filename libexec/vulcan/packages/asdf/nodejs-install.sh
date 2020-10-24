#!/usr/bin/env zsh

VERSION=$1
PROGRAMS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${PROGRAMS_DIR}/../../installers/asdf.sh

asdf_install_or_upgrade_package nodejs "${VERSION}" --pre-install-hook "${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring"
npm config set user 0
npm config set unsafe-perm true
npm install -g npm > /dev/null 2>&1
