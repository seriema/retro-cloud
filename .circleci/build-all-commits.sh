#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

. ./helpers.sh

logfile=$(createLog circleci build)
branch=$(git rev-parse --abbrev-ref HEAD)
# Skip the latest commit as it will be automatically built by the branch being pushed.
mapfile -t commits < <(git log "develop...HEAD~1" --format="%h")

for commit in "${commits[@]}"
do
    curl \
        -u "${CIRCLECI_API_USER_TOKEN}:" \
        --data "revision=$commit" \
        --data "branch=$branch" \
        "https://circleci.com/api/v1.1/project/github/seriema/retro-cloud/build" \
    | tee -a "$logfile"
done
