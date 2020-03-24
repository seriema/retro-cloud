#!/bin/bash
# shellcheck disable=SC1091
source /etc/profile.d/retro-cloud-dev.sh

# Abort on error, and error if variable is unset
set -eu

branch="$(git rev-parse --abbrev-ref HEAD)"

docker run \
    --rm \
    --volume "$PWD/docker/compose:/home/pi/retro-cloud-test/docker/compose" \
    --workdir "/home/pi/retro-cloud-test" \
    "rc:$branch" \
    ./docker/compose/run_tests.sh
