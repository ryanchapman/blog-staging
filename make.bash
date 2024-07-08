#!/bin/bash -

TRUE=0
FALSE=1

PARENTWD=$(dirname `pwd`)
REPONAME=$(basename `pwd`)

function log
{
    if [[ "${1}" == "FATAL" ]]; then
        fatal="FATAL"
        shift
    fi
    echo -n "$(date '+%b %d %H:%M:%S.%N %Z') $(basename -- $0)[$$]: "
    if [[ "${fatal}" == "FATAL" ]]; then echo -n "${fatal} "; fi
    echo "$*"
    if [[ "${fatal}" == "FATAL" ]]; then exit 1; fi
}

function run_ignerr
{
    _run warn $*
}

function run
{
    _run fatal $*
}

function _run
{
    if [[ $1 == fatal ]]; then
        errors_fatal=$TRUE
    else
        errors_fatal=$FALSE
    fi
    shift
    log "$*"
    eval "$*"
    rc=$?
    log "$* returned $rc"
    # fail hard and fast
    if [[ $rc != 0 && $errors_fatal == $TRUE ]]; then
        pwd
        exit 1
    fi
    return $rc
}

function clean
{
    log "Checking if we need to clean"
    if [[ -d site ]]; then
        log "Checking if we need to clean: yes"
        log "Cleaning mkdocs build artifacts"
        run "rm -rf site"
        log "Cleaning mkdocs build artifacts: done"
    else
        log "Checking if we need to clean: no"
    fi
}

function deps
{
    run python3 -m pip install openvino --break-system-packages --user
    run python3 -m pip install mkdocs --break-system-packages --user
    run python3 -m pip install mkdocs-redirects --break-system-packages --user
    run python3 -m pip install mkdocs-material --break-system-packages --user
    run python3 -m pip install ghp-import --break-system-packages --user
}

function local
{
    run python3 -m mkdocs serve
}

function build
{
    run python3 -m mkdocs build
}

function deploy
{
    run python3 -m mkdocs gh-deploy --force
}

function usage
{
    echo "usage: $(basename $0) <command> [arguments]"
    echo
    echo "Commands:"
    echo
    echo "    clean           Clean artifacts from a mkdocs build"
    echo "    deploy          Deploy site to github pages"
    echo "    deps            Install dependencies"
    echo "    local           Start local webserver for development"
    echo "    serve           Start local webserver for development"
    echo
}

#################################
# main
#################################

function main () {
    func_to_exec=${1:-usage}
    type ${func_to_exec} 2>&1 | grep -q 'function' >&/dev/null || {
        log "$(basename $0): ERROR: function '${func_to_exec}' not found."
        exit 1
    }

    shift
    ${func_to_exec} $*
    echo
}

# did someone source this file or execute it directly?  If not sourced, then we are responsible for
# executing main().  Files sourcing this one are responsible for calling main()
sourced=$FALSE
[ "$0" = "$BASH_SOURCE" ] || sourced=$TRUE

if [[ $sourced == $FALSE ]]; then
    main $*
fi

