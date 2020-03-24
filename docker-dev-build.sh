#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

branch="$(git rev-parse --abbrev-ref HEAD)"
tag="rc:$branch"

time docker build \
    --tag "$tag" \
    .

docker image history --human "$tag"
