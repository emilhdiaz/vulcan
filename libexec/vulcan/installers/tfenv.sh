#!/usr/bin/env zsh

tfenv_install() {
  local DFQN="${YELLOW}tfenv${NC}"
  local OS=$(get_os)

  if command -v tfenv &> /dev/null; then
    log_info "✅ ${DFQN} is already installed."
    return 0
  fi

  log_info "⚠️  ${DFQN} is not installed, installing..."

  # install via homebrew
  if command -v brew &> /dev/null; then
    (
      LOGLEVEL=ERROR
      install_or_upgrade_package brew unzip
      install_or_upgrade_package brew tfenv
    )

  # install manually with the help of apt-get and git
  elif command -v apt-get &> /dev/null; then
    (
      LOGLEVEL=ERROR
      install_or_upgrade_package apt unzip
      git clone -q https://github.com/tfutils/tfenv.git "$HOME/.tfenv"
      cd "$HOME/.tfenv" || return 1
      git checkout "$(git describe --abbrev=0 --tags)"
    )

  # cannot install
  else
    log_error "${DFQN} is not installed, but it cannot be installed with vulcan on ${OS} operating systems!"
    return 1

  fi

  log_info "✅ ${DFQN} installed."
}

tfenv_update() {
  local DFQN="${YELLOW}tfenv${NC}"
  local TFENV_DIR="$HOME/.tfenv"

  if ! command -v tfenv &> /dev/null; then
    log_error "${DFQN} is not installed!"
    return 1
  fi

  if brew list tfenv &> /dev/null; then
    brew upgrade tfenv

  elif [[ -d "$TFENV_DIR" ]]; then
    (
      cd "$TFENV_DIR" \
      && git fetch --tags origin \
      && git checkout "$(git describe --abbrev=0 --tags)"
    )

  fi
}

tfenv_install_or_upgrade_version() {
  require_tool tfenv

  local VERSION=${1:-}

  tfenv install "${VERSION}"
  tfenv use "${VERSION}"
}
