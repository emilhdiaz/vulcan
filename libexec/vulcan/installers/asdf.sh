#!/usr/bin/env zsh

INSTALLERS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${INSTALLERS_DIR}/../common.sh

asdf_install() {
  local DFQN="${YELLOW}asdf${NC}"
  local OS=$(get_os)

  if command -v asdf &> /dev/null; then
    log_info "✅ ${DFQN} is already installed."
    return 0
  fi

  log_info "⚠️  ${DFQN} is not installed, installing..."

  # install via homebrew
  if command -v brew &> /dev/null; then
    (
      LOGLEVEL=ERROR
      install_or_upgrade_package brew coreutils
      install_or_upgrade_package brew curl
      install_or_upgrade_package brew git
      install_or_upgrade_package brew unzip
      install_or_upgrade_package brew asdf
    )

  # install with the help of apt-get
  elif command -v apt-get &> /dev/null; then
    (
      LOGLEVEL=ERROR
      install_or_upgrade_package apt curl
      install_or_upgrade_package apt git
      install_or_upgrade_package apt unzip
      git clone -q https://github.com/asdf-vm/asdf.git "$HOME/.asdf"
      cd "$HOME/.asdf"
      git checkout "$(git describe --abbrev=0 --tags)"
    )

  # cannot install
  else
    log_error "${DFQN} is not installed, but it cannot be installed with vulcan on ${OS} operating systems!"
    return 1
  fi

  log_info "✅ ${DFQN} installed."

}

asdf_update() {
  local DFQN="${YELLOW}asdf${NC}"
  local ASDF_DIR="$HOME/.asdf"

  if ! command -v asdf &> /dev/null; then
    log_error "${DFQN} is not installed!"
    return 1
  fi

  if brew list asdf &> /dev/null; then
    brew upgrade asdf
  elif [[ -d "$ASDF_DIR" ]]; then
    asdf update
  fi
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
