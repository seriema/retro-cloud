#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

branch="$(git rev-parse --abbrev-ref HEAD)"
tag="rc:$branch"

timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"
logfile="logs/docker/build/${branch}-${timestamp}.log"
mkdir -p logs/docker/build

time DOCKER_BUILDKIT=1 docker build \
    --tag "$tag" \
    . \
2>&1 | tee -a "$logfile"

docker image history --human "$tag" | tee -a "$logfile"

echo
echo "Build logged to $logfile"
