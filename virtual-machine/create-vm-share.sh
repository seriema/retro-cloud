#!/bin/bash

# Abort on error
set -e
# Error if variable is unset
set -u

echo 'Create folders to look like a RetroPie installation'
gamelists="$RETROCLOUD_VM_SHARE/.emulationstation/gamelists"
downloadedMedia="$RETROCLOUD_VM_SHARE/.emulationstation/downloaded_media"
roms="$RETROCLOUD_VM_SHARE/RetroPie/roms"

sudo mkdir -p "$gamelists"
sudo mkdir -p "$downloadedMedia"
sudo mkdir -p "$roms"

echo 'Create folders for Skyscraper'
cache="$RETROCLOUD_VM_SHARE/cache"
sudo mkdir -p "$cache"

echo 'Add folder paths as environment variables'
echo "# RETRO-CLOUD: The environment variables below are from virtual-machine/create-vm-share.sh" | sudo tee -a "$HOME/.retro-cloud.env" > /dev/null
echo "export RETROCLOUD_SKYSCRAPER_GAMELISTFOLDER=$gamelists" | sudo tee -a "$HOME/.retro-cloud.env" > /dev/null
echo "export RETROCLOUD_SKYSCRAPER_MEDIAFOLDER=$downloadedMedia" | sudo tee -a "$HOME/.retro-cloud.env" > /dev/null
echo "export RETROCLOUD_ROMS=$roms" | sudo tee -a "$HOME/.retro-cloud.env" > /dev/null
echo "export RETROCLOUD_SKYSCRAPER_CACHEFOLDER=$cache" | sudo tee -a "$HOME/.retro-cloud.env" > /dev/null

echo 'Done!'
