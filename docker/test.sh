#!/bin/bash
# Accepts a tag (preferably the branch name) as an optional parameter used for the Docker image tag name.

# Abort on error, and error if variable is unset
set -eu

. ./helpers.sh
branch=${1:-"$(getBranch)"}
tag="rc:$branch"
logfile="$(createLog docker test)"

docker run \
    --rm \
    --volume "$PWD/docker/compose:/home/pi/retro-cloud-test/docker/compose" \
    --workdir "/home/pi/retro-cloud-test" \
    "$tag" \
    ./docker/compose/run_tests.sh \
2>&1 | tee -a "$logfile"

echo
echo "Test logged to $logfile"
