#!/bin/bash

# Abort on error
set -e
# Error if variable is unset
set -u

echo "Create a shareable directory for the Raspberry Pi to mount"

mkdir -p "$RETROCLOUD_SHARE/.emulationstation"
mkdir -p "$RETROCLOUD_SHARE/RetroPie"

# Symlink the folders to look like a RetroPie installation.
ln -s "$RETROCLOUD_SKYSCRAPER_GAMELISTFOLDER" "$RETROCLOUD_SHARE/.emulationstation"
ln -s "$RETROCLOUD_SKYSCRAPER_MEDIAFOLDER" "$RETROCLOUD_SHARE/.emulationstation"
ln -s "$RETROCLOUD_ROMS" "$RETROCLOUD_SHARE/RetroPie"

echo "Symlinked folders to $RETROCLOUD_SHARE"
