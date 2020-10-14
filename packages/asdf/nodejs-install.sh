#!/usr/bin/env zsh

VERSION=$1
PROGRAMS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${PROGRAMS_DIR}/../../lib/installers/asdf.sh

bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring' > /dev/null 2>&1
asdf_install_or_upgrade_package nodejs "${VERSION}"
npm install -g npm > /dev/null 2>&1
