#!/bin/bash
# https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux#create-a-persistent-mount-point-for-the-azure-file-share-with-etcfstab

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

# The samba credentials file should have been added during VM creation and should not be removed.
if [[ ! -f "$RETROCLOUD_AZ_FILE_SHARE_CREDENTIALS" ]]; then
    echo "Cannot mount Azure File Share without samba credentials. File missing: $RETROCLOUD_AZ_FILE_SHARE_CREDENTIALS";
fi

echo 'Install Prerequisites'

sudo apt-get update
sudo apt-get install cifs-utils


echo 'Mount the Azure File Share in the VMs shared folder'
mntPath="$RETROCLOUD_VM_SHARE"
# The folder is created during VM creation, but if unmount-az-share.sh has run then it's been deleted and needs to be recreated.
if [[ ! -d $mntPath ]]; then
    echo 'Create the shared folder because it was missing'
    mkdir -p "$mntPath"
fi

echo 'Add a persistent mount point entry for the Azure file share in /etc/fstab'
if ! grep -q "$RETROCLOUD_AZ_FILE_SHARE_URL $mntPath" /etc/fstab
then
    echo "# RETRO-CLOUD: The changes below were made by retro-cloud" | sudo tee -a /etc/fstab > /dev/null
    echo "$RETROCLOUD_AZ_FILE_SHARE_URL $mntPath cifs _netdev,nofail,vers=3.0,credentials=$RETROCLOUD_AZ_FILE_SHARE_CREDENTIALS,dir_mode=0777,file_mode=0777,serverino" | sudo tee -a /etc/fstab > /dev/null
else
    echo "/etc/fstab was not modified to avoid conflicting entries as this Azure file share was already present. You may want to double check /etc/fstab to ensure the configuration is as desired."
    echo "Aborting to avoid issues"
    exit 0
fi

# Debugging: Mount the drive without persisting it
# https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux#mount-the-azure-file-share-on-demand-with-mount
# Note: $RETROCLOUD_AZ_STORAGE_ACCOUNT_KEY is no longer stored as an environment variable. Need to read it from $RETROCLOUD_AZ_FILE_SHARE_CREDENTIALS file for the next line to work.
# sudo mount -t cifs $RETROCLOUD_AZ_FILE_SHARE_URL $mntPath -o _netdev,nofail,vers=3.0,username=$RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME,password=$RETROCLOUD_AZ_STORAGE_ACCOUNT_KEY,dir_mode=0777,file_mode=0777,serverino

echo 'Mount now to avoid a reboot'
sudo mount -a


echo 'Add folder paths as environment variables'
echo "# RETRO-CLOUD: The environment variables below are from virtual-machine/mount-az-share.sh" | sudo tee -a "$HOME/.retro-cloud.env" > /dev/null
# Note: RETROCLOUD_VM_SHARE and RETROCLOUD_VM_MOUNT_POINT are currently the same.
echo "export RETROCLOUD_VM_MOUNT_POINT=$mntPath" | sudo tee -a "$HOME/.retro-cloud.env" > /dev/null

echo 'Done!'
echo "File share mounted on $mntPath"
