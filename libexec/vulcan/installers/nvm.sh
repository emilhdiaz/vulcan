#!/usr/bin/env zsh

INSTALLERS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${INSTALLERS_DIR}/nvm-configure.sh

nvm_install() {
  local DFQN="${YELLOW}nvm${NC}"
  local OS=$(get_os)

  if command -v nvm &> /dev/null; then
    log_info "✅ ${DFQN} is already installed."
    return 0
  fi

  log_info "⚠️  ${DFQN} is not installed, installing..."

  # install via homebrew
  if command -v brew &> /dev/null; then
    (
      LOGLEVEL=ERROR
      install_or_upgrade_package brew nvm
    )

  # install manually with the help of apt-get and git
  elif command -v apt-get &> /dev/null; then
    (
      LOGLEVEL=ERROR
      install_or_upgrade_package apt build-essential
      install_or_upgrade_package apt libssl-dev
      git clone -q https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
      cd "$HOME/.nvm" || return 1
      git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
    )

  # cannot install
  else
    log_error "${DFQN} is not installed, but it cannot be installed with vulcan on ${OS} operating systems!"
    return 1
  fi

  log_info "✅ ${DFQN} installed."
}

nvm_update() {
  local DFQN="${YELLOW}nvm${NC}"
  local NVM_DIR="$HOME/.nvm"

  if ! command -v nvm &> /dev/null; then
    log_error "${DFQN} is not installed!"
    return 1
  fi

  if brew list nvm &> /dev/null; then
    brew upgrade nvm

  elif [[ -d "$NVM_DIR" ]]; then
    (
      cd "$NVM_DIR" || return 1
      git fetch --tags origin
      git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
    )

  fi
}

nvm_install_or_upgrade_version() {
  require_tool nvm

  local VERSION=${1:-}

  nvm install "${VERSION}"
  npm config set user 0
  npm config set unsafe-perm true
  npm install -g npm
}
