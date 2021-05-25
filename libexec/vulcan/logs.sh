RED='\033[0;31m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

timestamp() {
  current_time=$(date "+[%H:%M:%S]")
  echo "${current_time}"
  return 0
}

log_debug() {
  local MESSAGE=$1 && shift
  local LOGLEVELS=(DEBUG)
  if [[ ! ${LOGLEVELS[(ie)${LOGLEVEL}]} -le ${#LOGLEVELS} ]]; then
    return 0
  fi
  (>&2 echo "${MAGENTA}DEBUG $(timestamp):${NC} ${MESSAGE}")
  return 0
}

log_info() {
  local MESSAGE=$1 && shift
  local LOGLEVELS=(DEBUG INFO)
  if [[ ! ${LOGLEVELS[(ie)${LOGLEVEL}]} -le ${#LOGLEVELS} ]]; then
    return 0
  fi
  (>&2 echo "${CYAN}INFO $(timestamp):${NC} ${MESSAGE}")
  return 0
}

log_warn() {
  local MESSAGE=$1 && shift
  local LOGLEVELS=(DEBUG INFO WARN)
  if [[ ! ${LOGLEVELS[(ie)${LOGLEVEL}]} -le ${#LOGLEVELS} ]]; then
    return 0
  fi
  (>&2 echo "${YELLOW}WARN $(timestamp):${NC} ${MESSAGE}")
  return 0
}

log_error() {
  local MESSAGE=$1 && shift
  local LOGLEVELS=(DEBUG INFO WARN ERROR)
  if [[ ! ${LOGLEVELS[(ie)${LOGLEVEL}]} -le ${#LOGLEVELS} ]]; then
    return 0
  fi
  (>&2 echo "${RED}ERROR $(timestamp):${NC} ${MESSAGE}")
  return 0
}
