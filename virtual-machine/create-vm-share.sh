#!/bin/bash

# Abort on error
set -e
# Error if variable is unset
set -u

echo 'Create a shareable directory for the Raspberry Pi to mount'
sharePath="$HOME/retro-cloud-share"
mkdir -p "$sharePath/.emulationstation"
mkdir -p "$sharePath/RetroPie"

echo 'Symlink the folders to look like a RetroPie installation.'
ln -s "$RETROCLOUD_SKYSCRAPER_GAMELISTFOLDER" "$sharePath/.emulationstation"
ln -s "$RETROCLOUD_SKYSCRAPER_MEDIAFOLDER" "$sharePath/.emulationstation"
ln -s "$RETROCLOUD_ROMS" "$sharePath/RetroPie"

echo "Symlinked folders to $sharePath"

echo 'Done!'
