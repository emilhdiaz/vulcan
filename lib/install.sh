#!/usr/bin/env zsh

_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${_DIR}/common.sh
source ${_DIR}/installers/darwin.sh
source ${_DIR}/installers/asdf.sh
source ${_DIR}/installers/brew.sh

install_from_config() {
  local CONFIG=$1
  local LENGTH
  local PROGRAM
  local INSTALLER
  local VERSION

  LENGTH=$(yq r "${CONFIG}" --length installers)
  for ((i=0; i<=LENGTH-1; i++)); do
    INSTALLER=$(yq r "${CONFIG}" "installers[$i].name")

    log_info "Found installer ${YELLOW}${INSTALLER}${NC} in configuration file"

    darwin_install_or_upgrade_installer "${INSTALLER}"
    echo "\n"
  done


  LENGTH=$(yq r "${CONFIG}" --length packages)
  for ((i=0; i<=LENGTH-1; i++)); do
    PROGRAM=$(yq r "${CONFIG}" "packages[$i].name")
    INSTALLER=$(yq r "${CONFIG}" "packages[$i].installer")
    VERSION=$(yq r "${CONFIG}" "packages[$i].version")

    log_info "Found package ${YELLOW}${INSTALLER}:${PROGRAM}@${VERSION}${NC} in configuration file"

    darwin_install_or_upgrade_package "${INSTALLER}" "${PROGRAM}" "${VERSION}"
    echo "\n"
  done
}
