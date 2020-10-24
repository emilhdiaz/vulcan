#!/usr/bin/env zsh

VERSION=$1
PROGRAMS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${PROGRAMS_DIR}/../../installers/asdf.sh

asdf_install_or_upgrade_package helmsman "${VERSION}" --plugin https://github.com/jkrukoff-cb/asdf-helmsman.git
