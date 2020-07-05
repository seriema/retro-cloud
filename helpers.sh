#!/bin/bash
# Helper functions used in various dev scripts.

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

# This file is set by docker-dev-setup.sh, and is optional to have.
if [[ -f .env ]]; then
    # Disable lint: the .env file is git ignored so it can't be included for shellcheck (https://github.com/koalaman/shellcheck/wiki/SC1091)
    # shellcheck disable=SC1091
    source .env
fi

getBranch()
{
    git rev-parse --abbrev-ref HEAD
}

getArch()
{
    # The names are taken from https://github.com/docker-library/official-images#architectures-other-than-amd64
    case "$(uname -m)" in
        # Assume Windows running Linux containers
        x86_64) echo "amd64" ;;
        # Assume a Raspberry Pi 3
        armv7l) echo "arm32v7" ;;
        # Fail
        *) echo "Unknown architecture: $(uname -m)" &% exit 1 ;;
    esac
}

createLog()
{
    # Parameters:
    # $1: The area. E.g. rpi, vm, docker.
    # $2: The operation. E.g. build, run, test.

    # Split declaration and assignment (https://github.com/koalaman/shellcheck/wiki/SC2155)
    local branch
    branch="$(getBranch)"
    local timestamp
    timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"

    local logpath="logs/$1/$2"
    local logfile="$logpath/${branch}-${timestamp}.log"

    mkdir -p "$logpath"
    touch "$logfile"

    # "return" the result
    echo "$logfile"
}
