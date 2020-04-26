#!/bin/bash
# This is a horrible hack because Travis runs things in individual VM's, which has it's benefits,
# but to understand a build pipeline it's either digging through thousands of lines in one single
# log, or re-create the container and continue.
#
# Pass the container name to use as the first param, or the default will be "travisty".

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

containerName="${1:-travisty}"

# Start Docker
docker pull seriema/retro-cloud:latest-amd64
docker container create \
    --cap-add SYS_ADMIN \
    --device /dev/fuse \
    --env-file .env \
    --interactive \
    --rm \
    --tty \
    --name "$containerName" \
    --volume "$TRAVIS_BUILD_DIR":/home/pi/retro-cloud-source \
    --workdir /home/pi/retro-cloud-source \
    seriema/retro-cloud:latest-amd64
docker container start "$containerName"

# Recreate Docker container
docker exec "$containerName" /bin/bash -c "./raspberry-pi/install-ps.sh"
docker exec "$containerName" /usr/bin/pwsh -File "./raspberry-pi/install-az-module.ps1"
docker exec "$containerName" /bin/bash -c "./raspberry-pi/dev/recreate-env-vars.sh '${containerName}__retro-cloud'"
