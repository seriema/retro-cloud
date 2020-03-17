#!/bin/bash
source /etc/profile.d/retro-cloud-dev.sh

# Abort on error, and error if variable is unset
set -eu

branch="$(git rev-parse --abbrev-ref HEAD)"

docker run \
    --env AZURE_TENANT_ID="$RC_DEV_AZURE_TENANT_ID" \
    --env AZURE_SERVICE_PRINCIPAL_USER="$RC_DEV_AZURE_SERVICE_PRINCIPAL_USER" \
    --env AZURE_SERVICE_PRINCIPAL_SECRET="$RC_DEV_AZURE_SERVICE_PRINCIPAL_SECRET" \
    --interactive \
    --privileged \
    --rm \
    --tty \
    --volume azure-context:/home/pi/.Azure \
    --volume powershell-bin:/usr/bin \
    --volume powershell-install:/home/pi/powershell \
    "rc:$branch"
