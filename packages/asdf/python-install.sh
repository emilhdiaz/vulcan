#!/usr/bin/env zsh

VERSION=$1
PROGRAMS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${PROGRAMS_DIR}/../../lib/installers/asdf.sh

asdf_install_or_upgrade_package python "${VERSION}"
pip3 install --upgrade pip > /dev/null 2>&1
