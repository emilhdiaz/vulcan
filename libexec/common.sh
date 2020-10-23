LIBEXEC_DIR="$(dirname "$(greadlink -f "$0")")"
source ${LIBEXEC_DIR}/logs.sh
source ${LIBEXEC_DIR}/args.sh

rr() {
  find $1 -name "$2" -type f
}

grep2() {
  grep -lZR "$1" | xargs -0 grep -l "$2"
}

quote() {
  ruby -rcsv -ne 'puts CSV.generate_line(CSV.parse_line($_), :force_quotes=>true)' $1
}

version() {
  : <<DOC
Parses a semantic version so that it can easily be compared to another semantic
version using less than and greater than operators.
--------------------------------------------------------------------------------
DOC
  echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'
  return 0
}

func_exists() {
  # appended double quote is an ugly trick to make sure we do get a string -- if $1 is not a known command, type does not output anything
  [ x$(type -t $1) = xfunction ];
}

require_tool() {
  local TOOL=$1 && shift
  if ! command -v ${TOOL} &> /dev/null; then
    log_error "The '${TOOL}' command is required but cannot be found!" && exit 1
  fi
}

get_github_latest_release() {
  local REPO=$1 && shift
  curl --silent "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

get_os() {
  local OS

  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    OS="darwin"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="darwin"
  else
    log_error "The '$OSTYPE' operating system is not supported" && exit 1
  fi
  echo "${OS}"
}

get_default_os_package_manager() {
  local PM

  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    PM="brew"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    PM="brew"
  else
    log_error "The '$OSTYPE' operating system is not supported" && exit 1
  fi
  echo "${PM}"
}

get_shell_rc_file() {
: <<DOC
Determine the appropriate init script for your default interactive shell
--------------------------------------------------------------------------------
DOC

  set +eu
  local RC_FILE="$HOME/.bash_profile"
  if [ -f "$HOME/.rc" ]; then
    RC_FILE="$HOME/.rc"

  elif [ -n "$BASH_VERSION" ]; then
    RC_FILE="$HOME/.bashrc"

  elif [ -n "$ZSH_VERSION" ]; then
    RC_FILE="$HOME/.zshrc"
  fi

  touch ${RC_FILE}
  echo ${RC_FILE}
  set -eu

  return 0
}
