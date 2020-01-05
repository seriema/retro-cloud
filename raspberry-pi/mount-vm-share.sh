#!/bin/bash
# https://github.com/RetroPie/RetroPie-Setup/wiki/Running-ROMs-from-a-Network-Share#option-1-add-to-autostartsh-preferred-if-using-v40

# Abort on error
set -e
# Error if variable is unset
set -u

echo 'Install Prerequisites'
sudo apt-get update > /dev/null
sudo apt-get install sshfs > /dev/null

echo 'Create a folder for the mount point'
# Using a unique name for mounting to be convenient during development.
# TODO: RETROCLOUD_AZ_RESOURCE_GROUP is currently considered a debug name but perhaps I should save the generated "prefix" (or a system where Azure generates the names)
mntPath="/mnt/$RETROCLOUD_AZ_RESOURCE_GROUP"
sudo mkdir -p $mntPath
sudo chmod 777 $mntPath

echo 'Create a persistent mount point in autostart.sh'
# If these variables aren't available, make sure this script is running in interactive mode (https://stackoverflow.com/a/43660876) and create-vm.ps1.
mntCmd="sudo -u pi sshfs $RETROCLOUD_VM_USER@$RETROCLOUD_VM_IP:$RETROCLOUD_VM_SHARE $mntPath"
echo $mntCmd | sudo tee -a /opt/retropie/configs/all/autostart.sh > /dev/null

echo 'Mount now to avoid a reboot'
$mntCmd

echo 'Add folder paths as environment variables'
echo "" | sudo tee -a "$HOME/.bashrc" > /dev/null
echo "# RETRO-CLOUD: The environment variables below are from raspberry-pi/mount-vm-share.sh" | sudo tee -a "$HOME/.bashrc" > /dev/null
echo "# RETRO-CLOUD: These are mostly useful for troubleshooting." | sudo tee -a "$HOME/.bashrc" > /dev/null
echo "export RETROCLOUD_RPI_MOUNT_POINT=$mntPath" | sudo tee -a "$HOME/.bashrc" > /dev/null

echo 'Done!'
echo "VM share mounted on $mntPath"
