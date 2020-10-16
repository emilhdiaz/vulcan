#!/usr/bin/env zsh

INSTALLERS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${INSTALLERS_DIR}/../common.sh

brew_install() {
  DFQN="${YELLOW}brew${NC}"

  if ! command -v brew &> /dev/null; then
    log_info "⚠️  ${DFQN} is not installed, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    log_info "✅ ${DFQN} installed."
  else
    log_info "✅ ${DFQN} is already installed."
  fi
}

brew_get_current_formula() {
  local PROGRAM=$1 && shift
  PROGRAM=$(brew info --json "${PROGRAM}" | jq -r '.[].name')
  brew list --versions | grep "^${PROGRAM}@" | cut -d' ' -f1 | cut -d'@' -f2
}

brew_get_latest_formula() {
  local PROGRAM=$1 && shift
  echo ''
}

brew_get_current_version() {
  local PROGRAM=$1 && shift
  PROGRAM=$(brew info --json "${PROGRAM}" | jq -r '.[].name')
  brew list --versions | grep "^${PROGRAM}[@ ]" | head -n 1 | cut -d' ' -f2- | tr ' ' '\n' | sort -nr | head -n 1
}

brew_get_latest_version() {
  local PROGRAM=$1 && shift
  brew info --json "${PROGRAM}" | jq -r '.[].versions.stable'
}

brew_install_or_upgrade_package() {
  require_tool brew

  local PROGRAM=$1 && shift
  local TAP=$(parse_long_opt 'tap' '' "$@")
  local DESIRED_FORMULA=${1:-latest}
  local CURRENT_VERSION=$(brew_get_current_version "${PROGRAM}")
  local DESIRED_VERSION=${CURRENT_VERSION}

  # check if we need to register plugin
  if [ -n "${TAP}" ] &&  ! (brew tap | grep "${TAP}" > /dev/null 2>&1); then
    log_info "ℹ️️  Installing homebrew tap ${TAP}..."
    brew tap "${TAP}"
  fi

  # resolve "latest" version
  if [[ "$DESIRED_FORMULA" == "latest" ]]; then
    DESIRED_VERSION=$(brew_get_latest_version "${PROGRAM}")
  fi

  local DFQN="${YELLOW}${PROGRAM}@${DESIRED_VERSION}${NC}"
  local CFQN="${YELLOW}${PROGRAM}@${CURRENT_VERSION}${NC}"

  # check if we need to install
  if [ -z "${CURRENT_VERSION}" ]; then

    log_info "⚠️  ${DFQN} is not installed, installing..."
    if [[ "$DESIRED_FORMULA" != "latest" ]]; then
      brew install "${PROGRAM}@${DESIRED_FORMULA}"
      brew link --overwrite --force "${PROGRAM}@${DESIRED_FORMULA}"
    else
      brew install "${PROGRAM}"
    fi
    log_info "✅ ${DFQN} installed."

  # check if we need to upgrade
  elif [ $(version ${DESIRED_VERSION}) -gt $(version ${CURRENT_VERSION}) ]; then

    log_info "⚠️  Current version (${CFQN}) is older than desired version (${DFQN}), upgrading..."
    if [[ "$DESIRED_FORMULA" != "latest" ]]; then
      brew upgrade "${PROGRAM}@${DESIRED_FORMULA}"
      brew link --overwrite --force "${PROGRAM}@${DESIRED_FORMULA}"
    else
      brew upgrade "${PROGRAM}"
    fi
    log_info "✅ ${DFQN} installed."

  # check if a newer version already exists
  elif [ $(version ${DESIRED_VERSION}) -lt $(version ${CURRENT_VERSION}) ]; then
    log_info "⚠️  Current version (${CFQN}) is newer than desired version (${DFQN}), skipping..."

  # already installed and right version
  else
    log_info "✅ ${DFQN} is already installed."
  fi
}
