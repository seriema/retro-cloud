#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"
logfile="logs/docker/build/$(uname -m)-${timestamp}.log"
mkdir -p logs/docker/build

case "$(uname -m)" in
    # Assume Windows running Linux containers
    x86_64) tag="seriema/retro-cloud:amd64" ;;
    # Assume a Raspberry Pi 3
    armv7l) tag="seriema/retro-cloud:arm32v7" ;;
    # Fail
    *) echo "Unknown architecture: $(uname -m)" &% exit 1 ;;
esac

time DOCKER_BUILDKIT=1 docker build -t "$tag" . 2>&1 | tee "$logfile"

echo
echo "Build logged to $logfile"
