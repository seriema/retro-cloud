#!/bin/bash
#
# Builds and publishes a amd64 containerized image of Skyscraper: seriema/retro-cloud:scraper-bin
# ARM builds currently have no use as they would have to run on the Raspberry Pi: slowing it down, and not leveraging Azure.
#

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

. ./helpers.sh

# Verify that we're NOT on a Raspberry Pi
if [[ $(getArch) == "arm32v7" ]]; then
    echo 'Only build from Windows/Linux to create an AMD version of the Docker image.'
    exit 1
fi

# Push image to Docker Hub
tag="seriema/retro-cloud:scraper-bin"
docker push "$tag"

# Done
echo
echo 'Done.'
