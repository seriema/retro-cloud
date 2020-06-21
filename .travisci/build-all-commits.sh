#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

. ./helpers.sh

logfile=$(createLog circleci build)
branch=$(git rev-parse --abbrev-ref HEAD)
# Skip the latest commit as it will be automatically built by the branch being pushed.
mapfile -t commits < <(git log "develop...HEAD~1" --format="%h")

# To run some commits manually:
# commits=(0f143b4 abc1234)

for commit in "${commits[@]}"
do
    body="{
        \"request\": {
            \"branch\":\"$branch\",
            \"sha\":\"$commit\"
    }}"

    curl -X POST \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -H "Travis-API-Version: 3" \
        -H "Authorization: token $TRAVISCI_API_USER_TOKEN" \
        -d "$body" \
        'https://api.travis-ci.com/repo/seriema%2Fretro-cloud/requests' \
    | tee -a "$logfile"
done
