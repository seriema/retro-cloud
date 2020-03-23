#!/bin/bash
# shellcheck disable=SC1091
source /etc/profile.d/retro-cloud-dev.sh

# Abort on error, and error if variable is unset
set -eu

branch="$(git rev-parse --abbrev-ref HEAD)"

docker run \
    --cap-add SYS_ADMIN \
    --device /dev/fuse \
    --env AZURE_TENANT_ID="$RC_DEV_AZURE_TENANT_ID" \
    --env AZURE_SERVICE_PRINCIPAL_USER="$RC_DEV_AZURE_SERVICE_PRINCIPAL_USER" \
    --env AZURE_SERVICE_PRINCIPAL_SECRET="$RC_DEV_AZURE_SERVICE_PRINCIPAL_SECRET" \
    --interactive \
    --rm \
    --tty \
    --volume "$PWD":/home/pi/retro-cloud-source \
    --workdir /home/pi/retro-cloud-source \
    "rc:$branch"
