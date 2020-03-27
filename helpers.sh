#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

getBranch()
{
    git rev-parse --abbrev-ref HEAD
}

getArch()
{
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
