#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

branch="$(git rev-parse --abbrev-ref HEAD)"

docker run \
    --interactive \
    --privileged \
    --rm \
    --tty \
    --volume azure-context:/home/pi/.Azure \
    --volume "home-$branch":/home/pi \
    --volume powershell-bin:/usr/bin \
    --volume powershell-install:/home/pi/powershell \
    "rc:$branch"
