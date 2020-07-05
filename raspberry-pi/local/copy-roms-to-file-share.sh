#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

echo 'Copy all ROMs from backup folder to Azure File Share'
# Create the target directory first because rsync doesn't create it.
mkdir -p "$RETROCLOUD_RPI_MOUNT_POINT/RetroPie/roms"
rsync \
    --checksum \
    --human-readable \
    --itemize-changes \
    --progress \
    --recursive \
    -vv \
    "$HOME/RetroPie/roms.bak/" "$RETROCLOUD_RPI_MOUNT_POINT/RetroPie/roms/"

echo 'Done!'
echo "ROMs copied to $RETROCLOUD_RPI_MOUNT_POINT/RetroPie/roms"
