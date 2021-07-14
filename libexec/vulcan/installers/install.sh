#!/usr/bin/env zsh

INSTALLERS_DIR="$(dirname "$(greadlink -f "$0")")"
source ${INSTALLERS_DIR}/brew.sh
source ${INSTALLERS_DIR}/apt.sh
source ${INSTALLERS_DIR}/asdf.sh
source ${INSTALLERS_DIR}/sdk.sh
source ${INSTALLERS_DIR}/pipx.sh
source ${INSTALLERS_DIR}/nvm.sh
source ${INSTALLERS_DIR}/pyenv.sh
source ${INSTALLERS_DIR}/tfenv.sh

install_or_upgrade_installer() {
  local INSTALLER=$1 && shift

  if [ -n "${DRY_RUN}" ]; then
    return
  fi

  local CONFIGURE_SCRIPT=$(echo "${INSTALLER}" | sed -e 's/\//_/')"-configure.sh"
  local CONFIGURE_SCRIPT_PATH="${INSTALLERS_DIR}/${CONFIGURE_SCRIPT}"

  # install via brew
  if [[ "$INSTALLER" == "brew" ]]; then
    brew_install

  # install via apt
  elif [[ "$INSTALLER" == "apt" ]]; then
    apt_install

  # install via asdf
  elif [[ "$INSTALLER" == "asdf" ]]; then
    asdf_install

  # install via sdk
  elif [[ "$INSTALLER" == "sdk" ]]; then
    sdk_install

  # install via pipx
  elif [[ "$INSTALLER" == "pipx" ]]; then
    pipx_install

  # install via nvm
  elif [[ "$INSTALLER" == "nvm" ]]; then
    nvm_install

  # install via pyenv
  elif [[ "$INSTALLER" == "pyenv" ]]; then
    pyenv_install

  # install via tfenv
  elif [[ "$INSTALLER" == "tfenv" ]]; then
    tfenv_install

  # installer not supported
  else
    log_error "The '$INSTALLER' installer is not supported on darwin" && return 1
  fi

  # configure the shell if necessary
  if [ -f "${CONFIGURE_SCRIPT_PATH}" ]; then
    local RC_FILE=$(get_shell_rc_file)

    # remove any prior configuration for this script
    if (grep "${CONFIGURE_SCRIPT}" ${RC_FILE} > /dev/null 2>&1); then
      sed -ie "/${CONFIGURE_SCRIPT}/d" "${RC_FILE}"
    fi

    # install new configuration for this script
    log_info "Adding ${INSTALLER} to ${RC_FILE}"
    printf "[ -f '%s' ] && source '%s';\n" "${CONFIGURE_SCRIPT_PATH}" "${CONFIGURE_SCRIPT_PATH}" >> "${RC_FILE}"

    set +eu
    source "${CONFIGURE_SCRIPT_PATH}" silent
    set -eu
    log_info "✅ shell configured."
  fi
}

install_or_upgrade_package() {
  local INSTALLER=$1 && shift
  local PROGRAM=$1 && shift
  local VERSION=${1:-}
  local REPOSITORY=$(parse_long_opt 'repository' "$@")
  local REPOSITORY_URL=$(parse_long_opt 'repository-url' "$@")

  if [ -n "${DRY_RUN}" ]; then
    return
  fi

  local INSTALL_SCRIPT="${INSTALLERS_DIR}/../packages/${INSTALLER}/$(echo ${PROGRAM} | sed -e 's/\//_/')-install.sh"
  local CONFIGURE_SCRIPT="$(echo "${PROGRAM}" | sed -e 's/\//_/')-configure.sh"
  local CONFIGURE_SCRIPT_PATH="${INSTALLERS_DIR}/../packages/${INSTALLER}/${CONFIGURE_SCRIPT}"

  # install via custom script
  if [ -f "${INSTALL_SCRIPT}" ]; then
    "${INSTALL_SCRIPT}" "${VERSION}"

  # install via brew
  elif [[ "$INSTALLER" == "brew" ]]; then
    brew_install_or_upgrade_package "${PROGRAM}" "${VERSION}" \
      $([ -n "${REPOSITORY}" ] && echo "--tap ${REPOSITORY}") \
      $([ -n "${REPOSITORY_URL}" ] && echo "--tap-url ${REPOSITORY_URL}")

  # install via apt
  elif [[ "$INSTALLER" == "apt" ]]; then
    apt_install_or_upgrade_package "${PROGRAM}" "${VERSION}"

  # install via asdf
  elif [[ "$INSTALLER" == "asdf" ]]; then
    asdf_install_or_upgrade_package "${PROGRAM}" "${VERSION}" \
      $([ -n "${REPOSITORY}" ] && echo "--plugin ${REPOSITORY}") \
      $([ -n "${REPOSITORY_URL}" ] && echo "--plugin-url ${REPOSITORY_URL}")

  # install via sdk
  elif [[ "$INSTALLER" == "sdk" ]]; then
    sdk_install_or_upgrade_package "${PROGRAM}" "${VERSION}"

  # install via pipx
  elif [[ "$INSTALLER" == "pipx" ]]; then
    pipx_install_or_upgrade_package "${PROGRAM}" "${VERSION}"

  # install via nvm
  elif [[ "$INSTALLER" == "nvm" ]]; then
    nvm_install_or_upgrade_version "${VERSION}"

  # install via pyenv
  elif [[ "$INSTALLER" == "pyenv" ]]; then
    pyenv_install_or_upgrade_version "${VERSION}"

  # install via tfenv
  elif [[ "$INSTALLER" == "tfenv" ]]; then
    tfenv_install_or_upgrade_version "${VERSION}"

  # package manager not supported
  else
    log_error "The '$INSTALLER' package manager is not supported on darwin" && return 1
  fi

  # configure the shell if necessary
  if [ -f "${CONFIGURE_SCRIPT_PATH}" ]; then
    local RC_FILE=$(get_shell_rc_file)

    # remove any prior configuration for this script
    if (grep "${CONFIGURE_SCRIPT}" ${RC_FILE} > /dev/null 2>&1); then
      sed -ie "/${CONFIGURE_SCRIPT}/d" "${RC_FILE}"
    fi

    # install new configuration for this script
    log_info "Adding ${PROGRAM} to ${RC_FILE}"
    printf "[ -f '%s' ] && source '%s';\n" "${CONFIGURE_SCRIPT_PATH}" "${CONFIGURE_SCRIPT_PATH}" >> "${RC_FILE}"

    set +eu
    source "${CONFIGURE_SCRIPT_PATH}"
    set -eu
    log_info "✅ shell configured."
  fi
}
