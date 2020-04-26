#!/bin/bash
# Accepts a tag (preferably the branch name) as an optional parameter used for the Docker image tag name.
# Note: First time running this you want to run ./raspberry-pi/install-ps.sh. The PowerShell installation will then persist between containers through named volumes.

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

. ./helpers.sh
tag="seriema/retro-cloud:scraper-bin"

docker run --rm -it "$tag"
