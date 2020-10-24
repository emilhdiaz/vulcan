#!/usr/bin/env zsh

INSTALLERS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${INSTALLERS_DIR}/../common.sh

asdf_install() {
  ! command -v apt &> /dev/null && log_error "${DFQN} requires brew to be installed"

  install_or_upgrade_package brew asdf
}

asdf_get_current_version() {
  local PROGRAM=$1 && shift
  asdf current "${PROGRAM}" 2> /dev/null | tr -s " "| cut -d' ' -f2
}

asdf_get_latest_version() {
  local PROGRAM=$1 && shift
  asdf latest "$PROGRAM"
}

asdf_install_or_upgrade_package() {
  require_tool asdf

  local PROGRAM=$1 && shift
  local DESIRED_VERSION=${1:-latest}
  local CURRENT_VERSION=$(asdf_get_current_version "${PROGRAM}")
  local PLUGIN=$(parse_long_opt 'plugin' '' "$@")
  local PRE_INSTALL_HOOK=$(parse_long_opt 'pre-install-hook' '' "$@")

  # check if we need to register plugin
  if ! (asdf plugin list | grep "${PROGRAM}" > /dev/null 2>&1); then
    log_info "ℹ️️  Installing plugin repository ${PROGRAM} (${PLUGIN})..."
    asdf plugin add "${PROGRAM}" "${PLUGIN}"
  fi

  # resolve "latest" version
  if [[ "$DESIRED_VERSION" == "latest" ]]; then
    DESIRED_VERSION=$(asdf_get_latest_version "${PROGRAM}")
  fi

  local DFQN="${YELLOW}${PROGRAM}@${DESIRED_VERSION}${NC}"
  local CFQN="${YELLOW}${PROGRAM}@${CURRENT_VERSION}${NC}"

  # check if we need to install
  if [ -z "${CURRENT_VERSION}" ]; then

    [ -z "${PRE_INSTALL_HOOK}" ] && bash -c "${PRE_INSTALL_HOOK}" > /dev/null 2>&1

    log_info "⚠️  ${DFQN} is not installed, installing..."
    asdf install "${PROGRAM}" "${DESIRED_VERSION}"
    asdf global "${PROGRAM}" "${DESIRED_VERSION}"
    log_info "✅ ${DFQN} installed."

  # check if we need to change
  elif [ "${DESIRED_VERSION}" != "${CURRENT_VERSION}" ]; then

    log_info "⚠️  Current version (${CFQN}) does not match desired version (${DFQN}), updating..."
    asdf install "${PROGRAM}" "${DESIRED_VERSION}"
    asdf global "${PROGRAM}" "${DESIRED_VERSION}"
    log_info "✅ ${DFQN} installed."

  # already installed and right version
  else
    log_info "✅ ${DFQN} is already installed."
  fi
}
