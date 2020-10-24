#!/usr/bin/env zsh

INSTALLERS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${INSTALLERS_DIR}/../common.sh

apt_install() {
  DFQN="${YELLOW}apt${NC}"
  local OS=get_os

  [ ! "$OS" == "linux" ] && log_error "${DFQN} is not supported on $OS"

  if ! command -v apt &> /dev/null; then
    log_error "${DFQN} is not installed, but it cannot be installed with vulcan"
  else
    log_info "✅ ${DFQN} is already installed."
  fi
}

apt_get_current_version() {
  local PROGRAM=$1 && shift
  apt-cache policy "${PROGRAM}" | grep Installed: | cut -d' ' -f4
}

apt_get_latest_version() {
  local PROGRAM=$1 && shift
  set +eu
  apt-cache policy "${PROGRAM}" | grep Candidate: | cut -d' ' -f4
  set -eu
}

apt_install_or_upgrade_package() {
  require_tool apt-get

  local PROGRAM=$1 && shift
  local DESIRED_VERSION=${1:-latest}
  local CURRENT_VERSION=$(apt_get_current_version "${PROGRAM}")

  # resolve "latest" version
  if [[ "$DESIRED_VERSION" == "latest" ]]; then
    DESIRED_VERSION=$(apt_get_latest_version "${PROGRAM}")
  fi

  local DFQN="${YELLOW}${PROGRAM}@${DESIRED_VERSION}${NC}"
  local CFQN="${YELLOW}${PROGRAM}@${CURRENT_VERSION}${NC}"

  # check if we need to install
  if [ -z "${CURRENT_VERSION}" ]; then
    log_info "⚠️  ${DFQN} is not installed, installing..."
    apt-get install -y "${PROGRAM}=${DESIRED_VERSION}"
    log_info "✅ ${DFQN} installed."

  # check if we need to change
  elif [ "${DESIRED_VERSION}" != "${CURRENT_VERSION}" ]; then
    log_info "⚠️  Current version (${CFQN}) does not match desired version (${DFQN}), updating..."
    apt-get install -y --only-upgrade "${PROGRAM}=${DESIRED_VERSION}"
    log_info "✅ ${DFQN} installed."

  # already installed and right version
  else
    log_info "✅ ${DFQN} is already installed."
  fi
}