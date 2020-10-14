#!/usr/bin/env zsh

INSTALLERS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${INSTALLERS_DIR}/../common.sh
source ${INSTALLERS_DIR}/brew.sh
source ${INSTALLERS_DIR}/asdf.sh
source ${INSTALLERS_DIR}/sdk.sh
source ${INSTALLERS_DIR}/pipx.sh
source ${INSTALLERS_DIR}/nvm.sh
source ${INSTALLERS_DIR}/pyenv.sh
source ${INSTALLERS_DIR}/tfenv.sh

darwin_install_or_upgrade_installer() {
  local INSTALLER=$1 && shift

  if [ -n "${DRY_RUN}" ]; then
    return
  fi

  local CONFIGURE_SCRIPT="${INSTALLERS_DIR}/$(echo ${INSTALLER} | sed -e 's/\//_/')-configure.sh"

  # install via brew
  if [[ "$INSTALLER" == "brew" ]]; then
    brew_install

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
  if [ -f "${CONFIGURE_SCRIPT}" ]; then
    set +euE +o pipefail
    . "${CONFIGURE_SCRIPT}"
    log_info "✅ shell configured."
    set -euE -o pipefail
  fi
}

darwin_install_or_upgrade_package() {
  local INSTALLER=$1 && shift
  local PROGRAM=$1 && shift
  local VERSION=${1:-}

  if [ -n "${DRY_RUN}" ]; then
    return
  fi

  local INSTALL_SCRIPT="${INSTALLERS_DIR}/../../packages/${INSTALLER}/$(echo ${PROGRAM} | sed -e 's/\//_/')-install.sh"
  local CONFIGURE_SCRIPT="${INSTALLERS_DIR}/../../packages/${INSTALLER}/$(echo ${PROGRAM} | sed -e 's/\//_/')-configure.sh"

  # install via custom script
  if [ -f "${INSTALL_SCRIPT}" ]; then
    $SHELL "${INSTALL_SCRIPT}" "${VERSION}"

  # install via brew
  elif [[ "$INSTALLER" == "brew" ]]; then
    brew_install_or_upgrade_package "${PROGRAM}" "${VERSION}"

  # install via asdf
  elif [[ "$INSTALLER" == "asdf" ]]; then
    asdf_install_or_upgrade_package "${PROGRAM}" "${VERSION}"

  # install via sdk
  elif [[ "$INSTALLER" == "sdk" ]]; then
    sdk_install_or_upgrade_package "${PROGRAM}" "${VERSION}"

  # install via pipx
  elif [[ "$INSTALLER" == "pipx" ]]; then
    pipx_install_or_upgrade_package "${PROGRAM}" "${VERSION}"

  # install via nvm
  elif [[ "$INSTALLER" == "nvm" ]]; then
    nvm_install_or_upgrade_package "${VERSION}"

  # install via pyenv
  elif [[ "$INSTALLER" == "pyenv" ]]; then
    pyenv_install_or_upgrade_version "${VERSION}"

  # install via tfenv
  elif [[ "$INSTALLER" == "tfenv" ]]; then
    tfenv_install_or_upgrade_package "${VERSION}"

  # package manager not supported
  else
    log_error "The '$INSTALLER' package manager is not supported on darwin" && return 1
  fi

  # configure the shell if necessary
  if [ -f "${CONFIGURE_SCRIPT}" ]; then
    set +euE +o pipefail
    . "${CONFIGURE_SCRIPT}"
    log_info "✅ shell configured."
    set -euE -o pipefail
  fi
}
