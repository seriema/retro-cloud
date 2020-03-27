#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

. ./helpers.sh
tag="seriema/retro-cloud:$(getArch)"
logfile="$(createLog docker build)"

time DOCKER_BUILDKIT=1 docker build -t "$tag" . 2>&1 | tee -a "$logfile"

echo
echo "Build logged to $logfile"
