#!/usr/bin/env zsh

INSTALLERS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${INSTALLERS_DIR}/../common.sh

helm_plugin_install_or_upgrade_plugin() {
  require_tool helm

  local PLUGIN=$1 && shift
#  local DESIRED_VERSION=${1:-latest}
#  local CURRENT_VERSION=''
#  local GITHUB_REPO=$(echo "${PLUGIN}" | sed -e 's/https:\/\/github.com\///' | cut -d'.' -f1)
  local SHORTNAME=$(basename "${PLUGIN}" | cut -d'-' -f2 | cut -d'.' -f1 )

  # resolve "latest" version
#  if [[ "$DESIRED_VERSION" == "latest" ]]; then
#    DESIRED_VERSION=$(get_github_latest_release "${GITHUB_REPO}")
#  fi

#  local DFQN="${YELLOW}${PROGRAM}@${DESIRED_VERSION}${NC}"
#  local CFQN="${YELLOW}${PROGRAM}@${CURRENT_VERSION}${NC}"

  # check if we need to install
  if ! (helm plugin list | grep ${SHORTNAME} > /dev/null 2>&1); then
    log_info "⚠️  ${PLUGIN} is not installed, installing..."
    helm plugin install "${PLUGIN}"
    log_info "✅ ${PLUGIN} installed."

  # let's try to install via pip
  else
    log_info "⚠️  ${PLUGIN} already installed, attempting to upgrade..."
    helm plugin update "${SHORTNAME}" > /dev/null 2>&1
    log_info "✅ ${PLUGIN} upgraded."
  fi
}
