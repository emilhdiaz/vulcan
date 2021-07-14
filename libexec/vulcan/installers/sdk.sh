#!/usr/bin/env zsh

sdk_install() {
  DFQN="${YELLOW}sdk${NC}"

  if [[ ! -s "${HOME}/.sdkman/bin/sdkman-init.sh" ]]; then
    log_info "⚠️  ${DFQN} is not installed, installing..."
    curl -s "https://get.sdkman.io?rcupdate=false" | zsh
    log_info "✅ ${DFQN} installed."
  else
    log_info "✅ ${DFQN} is already installed."
  fi
}

sdk_get_current_version() {
  local PROGRAM=$1 && shift
  sdk current "${PROGRAM}" | grep version | cut -d' ' -f4
}

sdk_get_latest_version() {
  local PROGRAM=$1 && shift
  if [[ "${PROGRAM}" == "java" ]]; then
    sdk list "${PROGRAM}" | grep adpt | sed -n '1p' | cut -d'|' -f6 | tr -d ' '
  else
    sdk list "${PROGRAM}" | sed -n '4p' | sed -e 's/[>*+]//g' | awk '{print $1}'
  fi
}

sdk_install_or_upgrade_package() {
  set +eu

  require_tool sdk

  local PROGRAM=$1 && shift
  local DESIRED_VERSION=${1:-latest}
  local CURRENT_VERSION=$(sdk_get_current_version "${PROGRAM}")

  # resolve "latest" version
  if [[ "$DESIRED_VERSION" == "latest" ]]; then
    DESIRED_VERSION=$(sdk_get_latest_version "${PROGRAM}")
  fi

  local DFQN="${YELLOW}${PROGRAM}@${DESIRED_VERSION}${NC}"
  local CFQN="${YELLOW}${PROGRAM}@${CURRENT_VERSION}${NC}"

  # check if we need to install
  if [ -z "${CURRENT_VERSION}" ]; then

    log_info "⚠️  ${DFQN} is not installed, installing..."
    echo "N\n" | sdk install "${PROGRAM}" "${DESIRED_VERSION}"
    sdk default "${PROGRAM}" "${DESIRED_VERSION}" &> /dev/null
    log_info "✅ ${DFQN} installed."

  # check if we need to change
  elif [ "${DESIRED_VERSION}" != "${CURRENT_VERSION}" ]; then

    log_info "⚠️  Current version (${CFQN}) does not match desired version (${DFQN}), updating..."
    echo "N\n" | sdk install "${PROGRAM}" "${DESIRED_VERSION}"
    sdk default "${PROGRAM}" "${DESIRED_VERSION}" &> /dev/null
    log_info "✅ ${DFQN} installed."

  # already installed and right version
  else
    log_info "✅ ${DFQN} is already installed."
  fi

  set -eu
}