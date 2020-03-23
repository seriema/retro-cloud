#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

branch="$(git rev-parse --abbrev-ref HEAD)"
tag="rc:$branch"

time DOCKER_BUILDKIT=1 docker build \
    --tag "$tag" \
    .

docker image history --human "$tag"
