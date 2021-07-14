#!/usr/bin/env zsh

LIBEXEC_DIR="$(dirname "$(greadlink -f "$0")")"
source ${LIBEXEC_DIR}/installers/install.sh

list_installers_from_config() {
  local CONFIG=$1 && shift
  local INSTALLERS=()
  local COUNT=$(yqv "${CONFIG}" ".installers | length")

  local _i
  for ((_i=0; _i<=COUNT-1; _i++)); do
    local INSTALLER=$(yqv "${CONFIG}" ".installers[$_i].name")
    INSTALLERS+=("${INSTALLER}")
  done
  echo "${INSTALLERS[@]}"
}

list_required_packages_from_config() {
  local CONFIG=$1 && shift
  local YQ_PATH=$1
  local PACKAGES=()
  local COUNT=$(yqv "${CONFIG}" ".${YQ_PATH}.requires | length")

  local _i
  for ((_i=0; _i<=COUNT-1; _i++)); do
    local PACKAGE=$(yqv "${CONFIG}" ".${YQ_PATH}.requires[$_i]")
    PACKAGES+=("${PACKAGE}")
  done
  echo "${PACKAGES[@]}"
}

install_installers_from_config() {
  local CONFIG=$1

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
  local COUNT=$(yqv "${CONFIG}" ".packages | length")

  local _i
  for ((_i=0; _i<=COUNT-1; _i++)); do
    local PACKAGE=$(yqv "${CONFIG}" ".packages[$_i].name")
    local INSTALLER=$(yqv "${CONFIG}" ".packages[$_i].installer")
    local INSTALLER=${INSTALLER:-$(get_default_os_package_manager)}
    local VERSION=$(yqv "${CONFIG}" ".packages[$_i].version")
    local REPOSITORY=$(yqv "${CONFIG}" ".packages[$_i].repository")
    local REPOSITORY_URL=$(yqv "${CONFIG}" ".packages[$_i].repository-url")

    log_info "Found package ${YELLOW}${INSTALLER}:${PACKAGE}@${VERSION}${NC} in configuration file"

    local YQ_PATH="packages[$_i]"
    local REQUIRED_PACKAGES=( $(list_required_packages_from_config "${CONFIG}" "${YQ_PATH}") )
    for REQUIRED_PACKAGE in "${REQUIRED_PACKAGES[@]}"; do
      log_info "Found required OS dependency ${YELLOW}${REQUIRED_PACKAGE}${NC} in configuration file"
      install_or_upgrade_package "$(get_default_os_package_manager)" "${REQUIRED_PACKAGE}"
    done

    install_or_upgrade_package "${INSTALLER}" "${PACKAGE}" "${VERSION}" \
      $([ -n "${REPOSITORY}" ] && echo "--repository ${REPOSITORY}") \
      $([ -n "${REPOSITORY_URL}" ] && echo "--repository-url '${REPOSITORY_URL}'")
    echo "\n"
  done
}

install_all_from_config() {
  local CONFIG=$1

  install_installers_from_config "${CONFIG}"
  install_packages_from_config "${CONFIG}"
}
