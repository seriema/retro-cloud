#!/bin/bash
# Accepts two optional parameters:
# 1: The tag name, preferably the branch name, used as a Docker image tag name (i.e. seriema/retro-cloud:[tag]).
#    Default: current branch.
# 2: The repository name, useful when wanting to test an image from Docker Hub (i.e. [repository]:[tag]).
#    Default: "rc".
# Both omitted will use "rc:[branch]", i.e. "rc:develop".
# On CI it can be useful to call this script as "./docker/test.sh 'latest-amd64' 'seriema/retro-cloud'"

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

. ./helpers.sh
branch=${1:-"$(getBranch)"}
repo=${2:-"rc"}
tag="${repo}:$branch"
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
