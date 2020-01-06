#!/bin/bash

echo 'Remove symlinks'
rm "$RETROCLOUD_RPI_MOUNT_POINT/.emulationstation/gamelists"
rm "$RETROCLOUD_RPI_MOUNT_POINT/.emulationstation/downloaded_media"
rm "$RETROCLOUD_RPI_MOUNT_POINT/RetroPie/roms"

#TODO: all the other steps from mount-vm-share.sh
# /opt/retropie/configs/all/autostart.sh

echo 'Done!'
