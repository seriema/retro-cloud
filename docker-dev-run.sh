#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

# Accepts a tag (preferably the branch name) as an optional parameter for a command to send to the VM.
. ./helpers.sh
branch=${1:-"$(getBranch)"}
tag="rc:$branch"

docker run \
    --cap-add SYS_ADMIN \
    --device /dev/fuse \
    --env-file .env \
    --interactive \
    --rm \
    --tty \
    --volume "$PWD":/home/pi/retro-cloud-source \
    --workdir /home/pi/retro-cloud-source \
    "$tag"
