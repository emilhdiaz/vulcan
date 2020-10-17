#!/usr/bin/env zsh

INSTALLERS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${INSTALLERS_DIR}/../common.sh

pip_install() {
  echo "noop"
}

pip_get_current_version() {
  local PROGRAM=$1 && shift
  pip3 show ${PROGRAM} | grep Version: | cut -d' ' -f2
}

pip_get_latest_version() {
  local PROGRAM=$1 && shift
  set +eu
  pip3 install "${PROGRAM}==" 2>&1 | sed -E 's/.*from versions: (.*)\)/\1/' | head -n 1 | tr ', ' "\n" | sort -n | tail -1
  set -eu
}

pip_install_or_upgrade_package() {
  require_tool pip3

  local PROGRAM=$1 && shift
  local DESIRED_VERSION=${1:-latest}
  local CURRENT_VERSION=$(pip_get_current_version "${PROGRAM}")

  # resolve "latest" version
  if [[ "$DESIRED_VERSION" == "latest" ]]; then
    DESIRED_VERSION=$(pip_get_latest_version "${PROGRAM}")
  fi

  local DFQN="${YELLOW}${PROGRAM}@${DESIRED_VERSION}${NC}"
  local CFQN="${YELLOW}${PROGRAM}@${CURRENT_VERSION}${NC}"

  # check if we need to install
  if [ -z "${CURRENT_VERSION}" ]; then

    log_info "⚠️  ${DFQN} is not installed, installing..."
    pip3 install -q "${PROGRAM}==${DESIRED_VERSION}"
    log_info "✅ ${DFQN} installed."

  # check if we need to change
  elif [ "${DESIRED_VERSION}" != "${CURRENT_VERSION}" ]; then

    log_info "⚠️  Current version (${CFQN}) does not match desired version (${DFQN}), updating..."
    pip3 install -q "${PROGRAM}==${DESIRED_VERSION}"
    log_info "✅ ${DFQN} installed."

  # already installed and right version
  else
    log_info "✅ ${DFQN} is already installed."
  fi
}
