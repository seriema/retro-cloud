#!/bin/bash

# Abort on error
set -e
# Error if variable is unset
set -u

echo 'Create a shareable directory for the Raspberry Pi to mount'
mkdir -p "$RETROCLOUD_VM_SHARE/.emulationstation"
mkdir -p "$RETROCLOUD_VM_SHARE/RetroPie"

echo 'Symlink the folders to look like a RetroPie installation.'
# If these variables aren't available, make sure this script is running in interactive mode (https://stackoverflow.com/a/43660876) and mount-az-share.sh.
ln -s "$RETROCLOUD_SKYSCRAPER_GAMELISTFOLDER" "$RETROCLOUD_VM_SHARE/.emulationstation"
ln -s "$RETROCLOUD_SKYSCRAPER_MEDIAFOLDER" "$RETROCLOUD_VM_SHARE/.emulationstation"
ln -s "$RETROCLOUD_ROMS" "$RETROCLOUD_VM_SHARE/RetroPie"

echo "Symlinked folders to $RETROCLOUD_VM_SHARE"

echo 'Done!'
