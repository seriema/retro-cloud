#!/bin/bash
#
# Builds and publishes an ARM version of the Docker image: seriema/retro-cloud:latest-arm32v7
# AMD builds are handled by Docker Hub: seriema/retro-cloud:latest
#

# Abort on error, and error if variable is unset
set -eu

. ./helpers.sh

# Verify that we're on a Raspberry Pi
if [[ $(getArch) != "arm32v7" ]]; then
    echo 'Only build from a Raspberry Pi to create an arm version of the Docker image.'
    exit 1
fi

# Verify that we're on master
if [[ $(getBranch) != "master" ]]; then
    echo 'Only publish from master branch. Please get the latest master branch and try again.'
    exit 1
fi

# Verify that we're on the latest master
git fetch --prune
if [[ $(git rev-list HEAD...origin/master --count) -ne 0 ]]; then
    echo 'Only publish the latest from master branch. Please sync your local master branch with origin and try again.'
    exit 1
fi

# Build image
tag="seriema/retro-cloud:latest-arm32v7"
logfile="$(createLog docker build)"

time DOCKER_BUILDKIT=1 docker build \
    --tag "$tag" \
    . \
2>&1 | tee -a "$logfile"

# Push image to Docker Hub
docker push "$tag"

# Done
echo
echo "Build logged to $logfile"
echo 'Done.'
