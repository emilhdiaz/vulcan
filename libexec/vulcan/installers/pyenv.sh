#!/usr/bin/env zsh

pyenv_install() {
  local DFQN="${YELLOW}pyenv${NC}"
  local OS=$(get_os)

  if command -v pyenv &> /dev/null; then
    log_info "✅ ${DFQN} is already installed."
    return 0
  fi

  log_info "⚠️  ${DFQN} is not installed, installing..."

  # install via homebrew
  if command -v brew &> /dev/null; then
    (
      LOGLEVEL=ERROR
      install_or_upgrade_package brew pyenv
      install_or_upgrade_package brew pyenv-virtualenv
    )

  # install with the help of apt-get
  elif command -v apt-get &> /dev/null; then
    (
      LOGLEVEL=ERROR
      install_or_upgrade_package apt make
      install_or_upgrade_package apt build-essential
      install_or_upgrade_package apt libssl-dev
      install_or_upgrade_package apt zlib1g-dev
      install_or_upgrade_package apt libbz2-dev
      install_or_upgrade_package apt libreadline-dev
      install_or_upgrade_package apt libsqlite3-dev
      install_or_upgrade_package apt libncurses5-dev
      install_or_upgrade_package apt libncursesw5-dev
      install_or_upgrade_package apt tk-dev
      install_or_upgrade_package apt libffi-dev
      install_or_upgrade_package apt liblzma-dev
      install_or_upgrade_package apt python-openssl
      install_or_upgrade_package apt xz-utils
      install_or_upgrade_package apt wget
      install_or_upgrade_package apt curl
      install_or_upgrade_package apt llvm
      install_or_upgrade_package apt git
      git clone -q https://github.com/pyenv/pyenv.git "$HOME/.pyenv"
      git clone -q https://github.com/pyenv/pyenv-virtualenv.git "$HOME/.pyenv/plugins/pyenv-virtualenv"
      cd "$HOME/.pyenv" || return 1
      git checkout "$(git describe --abbrev=0 --tags)"
    )

  # cannot install
  else
    log_error "${DFQN} is not installed, but it cannot be installed with vulcan on ${OS} operating systems!"
    return 1
  fi

  log_info "✅ ${DFQN} installed."
}

pyenv_update() {
  local DFQN="${YELLOW}asdf${NC}"
  local PYENV_DIR="$HOME/.pyenv"

  if ! command -v pyenv &> /dev/null; then
    log_error "${DFQN} is not installed!"
    return 1
  fi

  if brew list pyenv &> /dev/null; then
    brew upgrade pyenv
  elif [[ -d "$PYENV_DIR" ]]; then
    pyenv update
  fi
}

pyenv_install_or_upgrade_version() {
  require_tool pyenv

  local VERSION=${1:-}

  pyenv install -v -s "${VERSION}"
  pyenv global "${VERSION}"
  pip3 install --upgrade pip
}
