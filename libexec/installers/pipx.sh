#!/usr/bin/env zsh

INSTALLERS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${INSTALLERS_DIR}/../common.sh
source ${INSTALLERS_DIR}/brew.sh

pipx_install() {
  brew_install_or_upgrade_package pipx
}

pipx_get_current_version() {
  local PROGRAM=$1 && shift
  pipx list | grep "package ${PROGRAM}" | cut -d' ' -f6 | cut -d',' -f1
}

pipx_get_latest_version() {
  local PROGRAM=$1 && shift
  set +eu
  pipx install --force "${PROGRAM}==" 2>&1 | sed -E 's/.*from versions: (.*)\)/\1/' | head -n 1 | tr ', ' "\n" | sort -n | tail -1
  set -eu
}

pipx_install_or_upgrade_package() {
  require_tool pipx

  local PROGRAM=$1 && shift
  local DESIRED_VERSION=${1:-latest}
  local CURRENT_VERSION=$(pipx_get_current_version "${PROGRAM}")

  # resolve "latest" version
  if [[ "$DESIRED_VERSION" == "latest" ]]; then
    DESIRED_VERSION=$(pipx_get_latest_version "${PROGRAM}")
  fi

  local DFQN="${YELLOW}${PROGRAM}@${DESIRED_VERSION}${NC}"
  local CFQN="${YELLOW}${PROGRAM}@${CURRENT_VERSION}${NC}"

  # check if we need to install
  if [ -z "${CURRENT_VERSION}" ]; then
    log_info "⚠️  ${DFQN} is not installed, installing..."
    pipx install "${PROGRAM}==${DESIRED_VERSION}"
    log_info "✅ ${DFQN} installed."

  # check if we need to change
  elif [ "${DESIRED_VERSION}" != "${CURRENT_VERSION}" ]; then
    log_info "⚠️  Current version (${CFQN}) does not match desired version (${DFQN}), updating..."
    pipx install "${PROGRAM}==${DESIRED_VERSION}"
    log_info "✅ ${DFQN} installed."

  # already installed and right version
  else
    log_info "✅ ${DFQN} is already installed."
  fi
}
