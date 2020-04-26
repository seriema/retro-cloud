#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

. ./helpers.sh
# Print each command (do not do this before including helpers.sh or .env, because it will print the secrets)
set -x

# Always use the branch name (i.e. do not accept an optional parameter to use a different name) so naming doesn't get confusing when using run/test.
subtag="vm"
tag="seriema/retro-cloud:$subtag"
logfile="$(createLog docker build)"

echo | tee -a "$logfile"
echo 'BUILD: Build image' | tee -a "$logfile"
time DOCKER_BUILDKIT=1 docker build \
    --tag "$tag" \
    --file virtual-machine/docker/vm.Dockerfile \
    . \
2>&1 | tee -a "$logfile"

echo | tee -a "$logfile"
echo 'BUILD: List layer sizes' | tee -a "$logfile"
docker image history --human "$tag" | tee -a "$logfile"

echo | tee -a "$logfile"
echo 'BUILD: Show image size' | tee -a "$logfile"
docker images | grep "$subtag" | tee -a "$logfile"

echo | tee -a "$logfile"
echo "BUILD: Build logged to $logfile"
# Assuming it built. The logging is currently swallowing docker build errors.
echo "BUILD: Image created as $tag"

echo
echo 'BUILD: Done.' | tee -a "$logfile"
