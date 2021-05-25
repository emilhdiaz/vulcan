require() {
: <<DOC
Accepts an array of variable names and checks if each of those variables is set
and not empty
--------------------------------------------------------------------------------
VARS        A series of variable names passed as function arguments
DOC
    VARS=("$@")
    for VAR in "${VARS[@]}"; do
        if [[ -z ${!VAR} ]]; then
            log_error "Option '--$(echo ${VAR} | tr '[:upper:]' '[:lower:]')' is required"
            return 1
        fi
    done
    return 0
}

_parse_arg() {
: <<DOC
Parses a positional argument supplied to the command and returns it's value
--------------------------------------------------------------------------------
ARG           The name to give the positional argument
IDX           The index of the positional argument
TYPE          (Optional) The data type of the option's value
ALLOWED        (Optional) The acceptable range of values for this argument
DOC
    local ARG=$1 && shift
    local IDX=$1 && shift
    local TYPE=$1 && shift
    local ALLOWED=$1 && shift
    local ARGS=("$@")
    log_debug "_ARG: ${ARG}"
    log_debug "_IDX: ${IDX}"
    log_debug "_TYPE: ${TYPE}"
    log_debug "_ALLOWED: ${ALLOWED}"
    log_debug "_ARGS: (${#ARGS})${ARGS[*]}"

    # check if no value was supplied
    if [[ ! -v argv[IDX] ]]; then
        log_error "Argument '${ARG}' requires a value to be supplied"
        return 1
    fi

    local VAL=${argv[IDX]}

    # check if value is in list of acceptable values
    if [[ -n "${VAL}" ]] && [[ "${ALLOWED}" != ":ANY:" ]]; then
        declare a=("${(@s/|/)ALLOWED}")
        if [[ ! ${a[(ie)${VAL}]} -le ${#a} ]]; then
            log_error "Argument '${ARG}=${VAL}' is invalid. Valid values are [${ALLOWED}]"
            return 1
        fi
    fi
    log_debug "_VAL=${VAL}"
    log_debug " "
    echo "${VAL}"
    return 0
}

_parse_long_opt() {
: <<DOC
Parses a long option supplied to the command and returns it's value
--------------------------------------------------------------------------------
OPT           The name of the option to parse
TYPE          (Optional) The data type of the option's value
ALLOWED       (Optional) The acceptable range of values for this option
DOC
    local OPT=$1 && shift
    local TYPE=$1 && shift
    local REQUIRED=$1 && shift
    local ALLOWED=$1 && shift
    local DEFAULT=$1 && shift
    local ARGS=("$@")
    local OPT_IDX
    local VAL_IDX
    local VAL
    log_debug "_OPT: ${OPT}"
    log_debug "_TYPE: ${TYPE}"
    log_debug "_REQUIRED: ${REQUIRED}"
    log_debug "_ALLOWED: ${ALLOWED}"
    log_debug "_ARGS: (${#ARGS})${ARGS[*]}"

    # identify the position of the option
    regexp="--[:@]?${OPT}"
    for ((i = 1; i <= $#ARGS; i++)); do
       [[ ${ARGS[i]} =~ $regexp ]] && OPT_IDX=${i} && break
    done

    # if not found, then set val to null
    if [[ -z "${OPT_IDX}" ]]; then
        VAL=

    # else if option is a boolean, then value is just "true"
    elif [[ "${TYPE}" == ":BOOL:" ]]; then
        VAL=":TRUE:"

    # else if format [opt=val], then attempt to get value from splitting on the '='
    elif [[ ${ARGS[OPT_IDX]} =~ ^(.*)=(.*)$ ]]; then
        VAL=${ARGS[OPT_IDX]#*=}
        # check if no value was supplied
        if [[ -z "${VAL}" ]]; then
            log_error "Option '--${OPT}' requires a value to be supplied"
            return 1
        fi

    # else (format [opt val]), attempt then grab value from next positional argument
    else
        VAL_IDX=$((OPT_IDX+1))
        VAL=${ARGS[VAL_IDX]}
        # check if no value was supplied
        if [[ ${VAL} =~ ^\- ]] || [[ -z "${VAL}" ]]; then
            log_error "Option '--${OPT}' requires a value to be supplied"
            return 1
        fi
    fi

    # check value against range of acceptable values
    if [[ ! -z ${VAL} ]] && [[ "${ALLOWED}" != ":ANY:" ]]; then
        declare a=("${(@s/|/)ALLOWED}")
        if [[ ! ${a[(ie)${VAL}]} -le ${#a} ]]; then
            log_error "Option --${OPT}=${VAL} is invalid. Valid options are [${ALLOWED}]"
            return 1
        fi
    fi

    log_debug "_VAL=${VAL}"
    log_debug " "

    [[ -n "${VAL}" ]] && echo "${VAL}" && return 0
    [[ "${DEFAULT}" != ':NONE:' ]] && echo "${DEFAULT}" && return 0
    [[ "${REQUIRED}" == ':TRUE:' ]] && log_error "Option '--${OPT}' requires a value to be supplied" && return 1
}

_strip_internal_long_opts() {
    local DELIMITER=$1 && shift
    local ARGVS
    local OPTS
    local ARGS

    ARGVS="$*"                                  # concatenate all remaining arguments together
    log_debug "1-ARGVS)${ARGVS}"

    ARGS="${ARGVS%%--*}"                        # split out the positional arguments
    log_debug "2-ARGS)${ARGS}"

    OPTS="${ARGVS#*--}"                         # split out the long opts
    log_debug "2-OPTS)${OPTS}"

    OPTS="${OPTS//=/ }"                         # replace equals with space in long opts
    log_debug "3-OPTS)${OPTS}"

    OPTS=(${(s/ --/)OPTS})                      # split long opts by delimiter
    log_debug "4-OPTS)(${#OPTS})${OPTS[*]}"

    [[ "${DELIMITER}" == "@" ]] && \
    OPTS=(${OPTS[*]//@*/})                      # remove the internal long opts (--@)
    log_debug "5-OPTS)(${#OPTS})${OPTS[*]}"

    [[ "${DELIMITER}" == ":" ]] && \
    OPTS=(${OPTS[*]//:*/})                      # remove the internal long opts (--:)
    log_debug "5-OPTS)(${#OPTS})${OPTS[*]}"

    OPTS=(${OPTS[*]/#/--})                      # rebuild the long opts with the delimiter
    log_debug "6-OPTS)(${#OPTS})${OPTS[*]}"

    OPTS="${OPTS[*]}"                           # re-concatenate long opts so that we can split again by space
    log_debug "7-OPTS)${OPTS}"

    OPTS=(${(s/ /)OPTS})                        # split by long opts by space
    log_debug "8-OPTS)(${#OPTS})${OPTS[*]}"

    ARGS=(${(s/ /)ARGS})                        # split by arguments by space
    log_debug "9-ARGS)(${#ARGS})${ARGS[*]}"

    ARGVS=( "${ARGS[@]}" "${OPTS[@]}" )         # concatenate positional arguments and long opts
    log_debug "10-ARGVS)(${#ARGVS})${ARGVS[*]}"

    echo "${ARGVS[@]}"
    return 0
}

parse_arg() {
    local ARG=$(_parse_arg 'ARG' 1 ':STR:' ':ANY:' "$@") && shift
    local IDX=$(_parse_arg 'IDX' 1 ':STR:' ':ANY:' "$@") && shift
    local TYPE=$(_parse_long_opt ':type' ':STR:' ':FALSE:' ':STR:|:BOOL:' ':STR:' "$@")
    local ALLOWED=$(_parse_long_opt ':allowed' ':STR:' ':FALSE:' ':ANY:' ':NONE:' "$@")
    local ARGVS=($(_strip_internal_long_opts ":" "$@"))

    log_debug "ARG=${ARG}"
    log_debug "IDX=${IDX}"
    log_debug "TYPE=${TYPE}"
    log_debug "ALLOWED=${ALLOWED}"
    log_debug "ARGVS=(${#ARGVS})${ARGVS[*]}"
    VAL=$(
      _parse_arg \
      "${ARG}" \
      "${IDX}" \
      $([ -n "${TYPE}" ] && echo "${TYPE}" || echo ":STR:") \
      $([ -n "${ALLOWED}" ] && echo "${ALLOWED}" || echo ":ANY:") \
      "${ARGVS[@]}"
    )

    log_debug "VAL=${VAL}"
    echo "${VAL}"
    return 0
}

parse_long_opt() {
    local OPT=$(_parse_arg 'OPT' 1 ':STR:' ':ANY:' "$@") && shift
    local TYPE=$(_parse_long_opt ':type' ':STR:' ':FALSE:' ':STR:|:BOOL:' ':STR:' "$@")
    local REQUIRED=$(_parse_long_opt ':required' ':BOOL:' ':FALSE:' ':TRUE:|:FALSE:' ':FALSE:' "$@")
    local ALLOWED=$(_parse_long_opt ':allowed' ':STR:' ':FALSE:' ':ANY:' ':NONE:' "$@")
    local DEFAULT=$(_parse_long_opt ':default' ':STR:' ':FALSE:' ':ANY:' ':NONE:' "$@")
    local ARGVS=($(_strip_internal_long_opts ":" "$@"))

    log_debug "OPT=${OPT}"
    log_debug "TYPE=${TYPE}"
    log_debug "REQUIRED=${REQUIRED}"
    log_debug "ALLOWED=${ALLOWED}"
    log_debug "DEFAULT=${DEFAULT}"
    log_debug "ARGVS=(${#ARGVS})${ARGVS[*]}"
    VAL=$(
      _parse_long_opt \
      "${OPT}" \
      "${TYPE}" \
      "${REQUIRED}" \
      $([ -n "${ALLOWED}" ] && echo "${ALLOWED}" || echo ":ANY:") \
      $([ -n "${DEFAULT}" ] && echo "${DEFAULT}" || echo ":NONE:") \
      "${ARGVS[@]}"
    )

    log_debug "VAL=${VAL}"
    echo "${VAL}"
    return 0
}
