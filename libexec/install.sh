#!/usr/bin/env zsh

LIBEXEC_DIR="$(dirname "$(greadlink -f "$0")")"
source ${LIBEXEC_DIR}/common.sh
source ${LIBEXEC_DIR}/installers/asdf.sh
source ${LIBEXEC_DIR}/installers/brew.sh


list_installers_from_config() {
  local CONFIG=$1 && shift
  local INSTALLERS=()
  local COUNT=$(yq r "${CONFIG}" --length "installers")

  local _i
  for ((_i=0; _i<=COUNT-1; _i++)); do
    local INSTALLER=$(yq r "${CONFIG}" "installers[$_i].name")
    INSTALLERS+=("${INSTALLER}")
  done
  echo "${INSTALLERS[@]}"
}

list_required_packages_from_config() {
  local CONFIG=$1 && shift
  local YQ_PATH=$1
  local PACKAGES=()
  local COUNT=$(yq r "${CONFIG}" --length "${YQ_PATH}.requires")

  local _i
  for ((_i=0; _i<=COUNT-1; _i++)); do
    local PACKAGE=$(yq r "${CONFIG}" "${YQ_PATH}.requires[$_i]")
    PACKAGES+=("${PACKAGE}")
  done
  echo "${PACKAGES[@]}"
}

install_installers_from_config() {
  local CONFIG=$1

  source "${LIBEXEC_DIR}/installers/$(get_os).sh"

  local INSTALLERS=( $(list_installers_from_config "${CONFIG}") )
  for INSTALLER in "${INSTALLERS[@]}"; do
    log_info "Found installer ${YELLOW}${INSTALLER}${NC} in configuration file"

    local YQ_PATH="installers[$((${INSTALLERS[(ie)$INSTALLER]} - 1))]"
    local REQUIRED_PACKAGES=( $(list_required_packages_from_config "${CONFIG}" "${YQ_PATH}") )
    for REQUIRED_PACKAGE in "${REQUIRED_PACKAGES[@]}"; do
      log_info "Found required OS dependency ${YELLOW}${REQUIRED_PACKAGE}${NC} in configuration file"
      install_or_upgrade_package "$(get_default_os_package_manager)" "${REQUIRED_PACKAGE}"
    done

    install_or_upgrade_installer "${INSTALLER}"
    echo "\n"
  done
}

install_packages_from_config() {
  local CONFIG=$1
  local COUNT=$(yq r "${CONFIG}" --length "packages")

  source "${LIBEXEC_DIR}/installers/$(get_os).sh"

  local _i
  for ((_i=0; _i<=COUNT-1; _i++)); do
    local PACKAGE=$(yq r "${CONFIG}" "packages[$_i].name")
    local INSTALLER=$(yq r "${CONFIG}" "packages[$_i].installer")
    local INSTALLER=${INSTALLER:-$(get_default_os_package_manager)}
    local VERSION=$(yq r "${CONFIG}" "packages[$_i].version")
    local TAP=$(yq r "${CONFIG}" "packages[$_i].tap")
    local TAP_URL=$(yq r "${CONFIG}" "packages[$_i].tap-url")

    log_info "Found package ${YELLOW}${INSTALLER}:${PACKAGE}@${VERSION}${NC} in configuration file"

    local YQ_PATH="packages[$_i]"
    local REQUIRED_PACKAGES=( $(list_required_packages_from_config "${CONFIG}" "${YQ_PATH}") )
    for REQUIRED_PACKAGE in "${REQUIRED_PACKAGES[@]}"; do
      log_info "Found required OS dependency ${YELLOW}${REQUIRED_PACKAGE}${NC} in configuration file"
      install_or_upgrade_package "$(get_default_os_package_manager)" "${REQUIRED_PACKAGE}"
    done

    install_or_upgrade_package "${INSTALLER}" "${PACKAGE}" "${VERSION}" \
      $([ -n "${TAP}" ] && echo "--tap ${TAP}") \
      $([ -n "${TAP_URL}" ] && echo "--tap-url ${TAP_URL}")
    echo "\n"
  done
}

install_all_from_config() {
  local CONFIG=$1

  install_installers_from_config "${CONFIG}"
  install_packages_from_config "${CONFIG}"
}
