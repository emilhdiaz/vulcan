#!/usr/bin/env zsh

VERSION=$1
PROGRAMS_DIR="$( cd "$( dirname "${(%):-%x}" )" >/dev/null 2>&1 && pwd )"
source ${PROGRAMS_DIR}/../../common.sh

OS=$(get_os)

if [[ "$OS" == "debian" ]]; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
  rm -rf aws*
elif [[ "$OS" == "darwin" ]]; then
  curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
  sudo installer -pkg AWSCLIV2.pkg -target /
  rm -rf AWSCLIV2.pkg
else
  log_error "The '$OSTYPE' operating system is not supported" && exit 1
fi
