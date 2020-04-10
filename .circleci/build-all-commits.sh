#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

. ./helpers.sh

logfile=$(createLog circleci build)
branch=$(git rev-parse --abbrev-ref HEAD)
# Skip the latest commit as it will be automatically built by the branch being pushed.
mapfile -t commits < <(git log "develop...HEAD~1" --format="%h")
jobs=( bashValidation imageValidation scriptValidation )

for commit in "${commits[@]}"
do
    for job in "${jobs[@]}"
    do
        # https://circleci.com/docs/2.0/api-job-trigger/#overview
        curl -u "${CIRCLECI_API_USER_TOKEN}:" \
            --data "build_parameters[CIRCLE_JOB]=$job" \
            --data "build_parameters[CIRCLE_COMPARE_URL]=https://github.com/seriema/retro-cloud/compare/develop...$branch" \
            --data "revision=$commit" \
            "https://circleci.com/api/v1.1/project/github/seriema/retro-cloud/tree/${branch}" \
        | tee -a "$logfile"
    done
done
