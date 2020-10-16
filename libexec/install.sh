#!/usr/bin/env zsh

_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${_DIR}/common.sh
source ${_DIR}/installers/asdf.sh
source ${_DIR}/installers/brew.sh


list_installers_from_config() {
  local CONFIG=$1 && shift
  local INSTALLERS=()
  COUNT=$(yq r "${CONFIG}" --length "installers")
  for ((i=0; i<=COUNT-1; i++)); do
    INSTALLER=$(yq r "${CONFIG}" "installers[$i].name")
    INSTALLERS+=("${INSTALLER}")
  done
  echo "${INSTALLERS[@]}"
}

list_required_packages_from_config() {
  local CONFIG=$1 && shift
  local YQ_PATH=$1
  local PACKAGES=()
  COUNT=$(yq r "${CONFIG}" --length "${YQ_PATH}.requires")
  for ((i=0; i<=COUNT-1; i++)); do
    PACKAGE=$(yq r "${CONFIG}" "${YQ_PATH}.requires[$i]")
    PACKAGES+=("${PACKAGE}")
  done
  echo "${PACKAGES[@]}"
}

install_installers_from_config() {
  local CONFIG=$1

  source "${_DIR}/installers/$(get_os).sh"

  local INSTALLERS=( $(list_installers_from_config "${CONFIG}") )
  for INSTALLER in "${INSTALLERS[@]}"; do
    log_info "Found installer ${YELLOW}${INSTALLER}${NC} in configuration file"

    install_or_upgrade_installer "${INSTALLER}"
    echo "\n"
  done
}

install_packages_from_config() {
  local CONFIG=$1
  local INSTALLER
  local PACKAGE
  local VERSION
  local TAP

  source "${_DIR}/installers/$(get_os).sh"

  COUNT=$(yq r "${CONFIG}" --length "packages")
  for ((i=0; i<=COUNT-1; i++)); do
    PACKAGE=$(yq r "${CONFIG}" "packages[$i].name")
    INSTALLER=$(yq r "${CONFIG}" "packages[$i].installer")
    INSTALLER=${INSTALLER:-$(get_default_os_package_manager)}
    VERSION=$(yq r "${CONFIG}" "packages[$i].version")
    TAP=$(yq r "${CONFIG}" "packages[$i].tap")

    log_info "Found package ${YELLOW}${INSTALLER}:${PACKAGE}@${VERSION}${NC} in configuration file"

    REQUIRED_PACKAGES=( $(list_required_packages_from_config "${CONFIG}" "packages[$i]") )
    for REQUIRED_PACKAGE in "${REQUIRED_PACKAGES[@]}"; do
      log_info "Found required OS dependency ${YELLOW}${REQUIRED_PACKAGE}${NC} in configuration file"
      install_or_upgrade_package "$(get_default_os_package_manager)" "${REQUIRED_PACKAGE}"
    done

    install_or_upgrade_package "${INSTALLER}" "${PACKAGE}" "${VERSION}" $([ -n "${TAP}" ] && echo "--tap ${TAP}")
    echo "\n"
  done
}

install_all_from_config() {
  local CONFIG=$1

  install_installers_from_config "${CONFIG}"
  install_packages_from_config "${CONFIG}"
}
