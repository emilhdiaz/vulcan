#!/usr/bin/env zsh

npm_install() {
  echo "noop"
}

npm_get_current_version() {
  local PROGRAM=$1 && shift
  npm list -g --depth=0 | grep ${PROGRAM} | cut -d'@' -f2
}

npm_get_latest_version() {
  local PROGRAM=$1 && shift
  npm show "${PROGRAM}" version
}

npm_install_or_upgrade_package() {
  require_tool npm

  local PROGRAM=$1 && shift
  local DESIRED_VERSION=${1:-latest}
  local CURRENT_VERSION=$(npm_get_current_version "${PROGRAM}")

  # resolve "latest" version
  if [[ "$DESIRED_VERSION" == "latest" ]]; then
    DESIRED_VERSION=$(npm_get_latest_version "${PROGRAM}")
  fi

  local DFQN="${YELLOW}${PROGRAM}@${DESIRED_VERSION}${NC}"
  local CFQN="${YELLOW}${PROGRAM}@${CURRENT_VERSION}${NC}"

  # check if we need to install
  if [ -z "${CURRENT_VERSION}" ]; then

    log_info "⚠️  ${DFQN} is not installed, installing..."
    npm install -g "${PROGRAM}@${DESIRED_VERSION}"
    log_info "✅ ${DFQN} installed."

  # check if we need to change
  elif [ "${DESIRED_VERSION}" != "${CURRENT_VERSION}" ]; then

    log_info "⚠️  Current version (${CFQN}) does not match desired version (${DFQN}), updating..."
    npm install -g "${PROGRAM}@${DESIRED_VERSION}"
    log_info "✅ ${DFQN} installed."

  # already installed and right version
  else
    log_info "✅ ${DFQN} is already installed."
  fi
}