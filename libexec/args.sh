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

parse_arg() {
: <<DOC
Parses a positional argument supplied to the command and returns it's value
--------------------------------------------------------------------------------
ARG         The name to give the positional argument
IDX         The index of the positional argument
VALUES      (Optional) The acceptable range of values for this argument
DOC
    local ARG=$1 && shift
    local IDX=$1 && shift
    local VALUES=$1 && shift
    local VAL=${argv[IDX]}
    # check if no value was supplied
    if [[ ${VAL} =~ ^\- ]] || [[ -z ${VAL} ]]; then
        log_error "Argument '${ARG}' requires a value to be supplied"
        return 1
    fi
    # check if value is in list of acceptable values
    if [[ ! -z "${VALUES}" ]]; then
        declare a=("${(@s/|/)VALUES}")
        if [[ ! ${a[(ie)${VAL}]} -le ${#a} ]]; then
            log_error "Argument '${ARG}=${VAL}' is invalid. Valid values are [${VALUES}]"
            return 1
        fi
    fi
    echo ${VAL}
    return 0
}

parse_long_opt() {
: <<DOC
Parses a long option supplied to the command and returns it's value
--------------------------------------------------------------------------------
OPT         The name of the option to parse
VALUES      (Optional) The acceptable range of values for this option
DOC
    local OPT=$1 && shift
    local VALUES=$1 && shift
    local ARGS=("$@")
    local OPT_IDX=
    local VAL_IDX=
    local VAL=
    # identify the position of the option
    regexp="--${OPT}"
    for i in {1..$#argv}; do
       [[ ${argv[i]} =~ $regexp ]] && OPT_IDX=${i} && break
    done
    # if not found, then set val to null
    if [[ -z "${OPT_IDX}" ]]; then
        VAL=
    # else if option is a boolean, then value is just "true"
    elif [[ "${VALUES}" == "true" ]]; then
        VAL="true"
    # else if format [opt=val], then attempt to get value from splitting on the '='
    elif [[ ${argv[OPT_IDX]} =~ ^(.*)=(.*)$ ]]; then
        VAL=${argv[OPT_IDX]#*=}
        # check if no value was supplied
        if [[ -z ${VAL} ]]; then
            log_error "Option '--${OPT}' requires a value to be supplied"
            return 1
        fi
    # else (format [opt val]), attempt then grab value from next positional argument
    else
        VAL_IDX=$((OPT_IDX+1))
        VAL=${argv[VAL_IDX]}
        # check if no value was supplied
        if [[ ${VAL} =~ ^\- ]] || [[ -z ${VAL} ]]; then
            log_error "Option '--${OPT}' requires a value to be supplied"
            return 1
        fi
    fi
    # check value against range of acceptable values
    if [[ ! -z ${VAL} ]] && [[ ! -z "${VALUES}" ]]; then
        declare a=("${(@s/|/)VALUES}")
        if [[ ! ${a[(ie)${VAL}]} -le ${#a} ]]; then
            log_error "Option --${OPT}=${VAL} is invalid. Valid options are [${VALUES}]"
            return 1
        fi
    fi
    echo ${VAL}
    return 0
}