#!/bin/bash

# Do not abort on error as it might be an incomplete installation
# set -e
# Error if variable is unset
set -u

echo 'Unmount the Azure File Share in the VMs shared folder.'
mntPath="$RETROCLOUD_VM_SHARE"
sudo umount "$mntPath"
sudo rm -r -f "$mntPath"

# Do not delete it because it can't be recreated from within the VM
# echo 'Delete the credential file that stores the username and password for the file share.'
# sudo rm -f $RETROCLOUD_AZ_FILE_SHARE_CREDENTIALS

echo 'Remove the persistent mount point entry for the Azure file share in /etc/fstab'
sudo sed -i.bak "/RETRO-CLOUD/d" /etc/fstab
# Search for the account name because it doesn't include any strange characters that can break sed
sudo sed -i.bak "/$RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME/d" /etc/fstab

echo 'Done!'
