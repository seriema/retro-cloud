#!/bin/bash
# Starts a basic container using a release image.

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

. ./helpers.sh

echo 'START: Get the latest release image'
tag="seriema/retro-cloud:latest-$(getArch)"
docker pull "$tag"

echo 'START: Create a machine specific container'
if [[ $(getArch) == "arm32v7" ]]; then # Raspberry Pi
    # docker-compose up -d, prints statuses that interfere with getting the container name so we need to get the container id with docker-compose ps.
    docker-compose -f docker-compose.yml -f docker-compose.arm32v7.yml up -d --remove-orphan
    containerInstance=$(docker-compose ps -q)

    # NOTE: docker-compose does not support cp (https://github.com/docker/compose/issues/3593)
    # We need the RPi configured controllers to connect and they need to be writable because EmulationStation always writes to them, but not risk breaking the RPi configs
    docker cp --follow-link /opt/retropie/configs/all/retroarch/. "${containerInstance}:/opt/retropie/configs/all/retroarch"
    # We need the configs but cannot copy the whole EmulationStation folder if this container is to mimic a user's RetroPie
    docker cp /opt/retropie/configs/all/emulationstation/es_input.cfg "${containerInstance}:/opt/retropie/configs/all/emulationstation/es_input.cfg"
    docker cp /opt/retropie/configs/all/emulationstation/es_temporaryinput.cfg "${containerInstance}:/opt/retropie/configs/all/emulationstation/es_temporaryinput.cfg"

    # Run the prepared container
    echo "START: Run the prepared container '$containerInstance'"
    docker container start --attach --interactive "$containerInstance"

else # Windows
    docker-compose run --rm rpi bash
fi

# Do not copy the host's SSH keys, if this container is to mimic a user's RetroPie

echo 'START: Take down the container'
docker-compose down

echo 'START: Done.'
