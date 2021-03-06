#!/bin/bash
# https://github.com/RetroPie/RetroPie-Setup/wiki/Running-ROMs-from-a-Network-Share#option-1-add-to-autostartsh-preferred-if-using-v40

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

echo 'Install Prerequisites'
sudo apt-get update
sudo apt-get install -y sshfs

echo 'Create a folder for the mount point'
# Using a unique name for mounting to be convenient during development.
# TODO: RETROCLOUD_AZ_RESOURCE_GROUP is currently considered a debug name but perhaps I should save the generated "prefix" (or a system where Azure generates the names)
# If these variables aren't available, make sure this script is running in interactive mode (https://stackoverflow.com/a/43660876) and mount-az-share.sh.
mntPath="/mnt/$RETROCLOUD_AZ_RESOURCE_GROUP"
sudo mkdir -p "$mntPath"
sudo chmod 777 "$mntPath"

echo 'Create a persistent mount point in autostart.sh'
# If these variables aren't available, make sure this script is running in interactive mode (https://stackoverflow.com/a/43660876) and create-vm.ps1.
mntCmd="sudo -u pi sshfs $RETROCLOUD_VM_USER@$RETROCLOUD_VM_IP:$RETROCLOUD_VM_SHARE $mntPath"
# The last entry is starting emulationstation, and mounting the drives needs to happen first. Appending to the top with sed: https://stackoverflow.com/a/9533736
# autostart.sh not found
# sed error unknown option to s'
sudo sed -i "1s+^+$mntCmd\n+" /opt/retropie/configs/all/autostart.sh

echo 'Attempt to mount VM now to avoid a reboot ...'
# Allow it to fail. Which can happen in a container without privileges, or certain access rights issues.
if $mntCmd
then
    echo '... mounted successfully.'
else
    echo '... WARNING! Could not mount VM. You need to restart before continuing. It could also be a problem with your privilegies.' 1>&2
fi

echo 'Backup gamelists as ~/.emulationstation/gamelists.bak'
mv -v "${HOME}/.emulationstation/gamelists" "${HOME}/.emulationstation/gamelists.bak"

echo 'Backup downloaded media as ~/.emulationstation/downloaded_media.bak'
mv -v "${HOME}/.emulationstation/downloaded_media" "${HOME}/.emulationstation/downloaded_media.bak" || echo 'Directory unavailable. Assuming a fresh install where EmulationStation has not run yet.'

echo 'Backup ROMs as ~/RetroPie/roms.bak'
mv -v "${HOME}/RetroPie/roms" "${HOME}/RetroPie/roms.bak"

echo 'Symlink the mounted folders to look like a RetroPie installation'
gamelists="$mntPath/.emulationstation/gamelists"
downloadedMedia="$mntPath/.emulationstation/downloaded_media"
roms="$mntPath/RetroPie/roms"
ln -s "$gamelists" "$HOME/.emulationstation"
ln -s "$downloadedMedia" "$HOME/.emulationstation"
ln -s "$roms" "$HOME/RetroPie"

envVarFile="$HOME/.retro-cloud.env"
echo "Add folder paths as environment variables in $envVarFile"
echo "# RETRO-CLOUD: The environment variables below are from raspberry-pi/mount-vm-share.sh" | sudo tee -a "$envVarFile" > /dev/null
echo "export RETROCLOUD_RPI_MOUNT_POINT=$mntPath" | sudo tee -a "$envVarFile" > /dev/null

echo 'Done!'
echo "VM share mounted on $mntPath"
