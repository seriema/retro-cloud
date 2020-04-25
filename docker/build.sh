#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

. ./helpers.sh
# Always use the branch name (i.e. do not accept an optional parameter to use a different name) so naming doesn't get confusing when using run/test.
tag="rc:$(getBranch)"
logfile="$(createLog docker build)"

time DOCKER_BUILDKIT=1 docker build \
    --tag "$tag" \
    . \
2>&1 | tee -a "$logfile"

docker image history --human "$tag" | tee -a "$logfile"

echo
echo "Build logged to $logfile"
# Assuming it built. The logging is currently swallowing docker build errors.
echo "Image created as $tag"
