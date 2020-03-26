#!/bin/bash
# https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux#create-a-persistent-mount-point-for-the-azure-file-share-with-etcfstab

# Abort on error
set -e
# Error if variable is unset
set -u

echo 'Install Prerequisites'

sudo apt-get update
sudo apt-get install cifs-utils


echo 'Mount the Azure File Share in the VMs shared folder'
mntPath="$RETROCLOUD_VM_SHARE"

echo 'Create a credential file to store the username and password for the file share.'
if [ ! -d "/etc/smbcredentials" ]; then
    sudo mkdir "/etc/smbcredentials"
fi

smbCredentialFile="/etc/smbcredentials/$RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME.cred"
if [ ! -f $smbCredentialFile ]; then
    echo "username=$RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME" | sudo tee $smbCredentialFile > /dev/null
    echo "password=$RETROCLOUD_AZ_STORAGE_ACCOUNT_KEY" | sudo tee -a $smbCredentialFile > /dev/null
    echo "Credential file $smbCredentialFile created"

    echo 'Change permissions on the credential file so only root can read or modify the password file.'
    sudo chmod 600 $smbCredentialFile
else
    echo "The credential file $smbCredentialFile already exists, and was not modified."
fi

echo 'Create a persistent mount point for the Azure file share with /etc/fstab'
if [ -z "$(grep $RETROCLOUD_AZ_FILE_SHARE_URL\ $mntPath /etc/fstab)" ]; then
    echo "# RETRO-CLOUD: The changes below were made by retro-cloud" | sudo tee -a /etc/fstab > /dev/null
    echo "$RETROCLOUD_AZ_FILE_SHARE_URL $mntPath cifs _netdev,nofail,vers=3.0,credentials=$smbCredentialFile,dir_mode=0777,file_mode=0777,serverino" | sudo tee -a /etc/fstab > /dev/null
else
    echo "/etc/fstab was not modified to avoid conflicting entries as this Azure file share was already present. You may want to double check /etc/fstab to ensure the configuration is as desired."
    echo "Aborting to avoid issues"
    exit 0
fi

# Debugging: Mount the drive without persisting it
# https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux#mount-the-azure-file-share-on-demand-with-mount
# sudo mount -t cifs $RETROCLOUD_AZ_FILE_SHARE_URL $mntPath -o _netdev,nofail,vers=3.0,username=$RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME,password=$RETROCLOUD_AZ_STORAGE_ACCOUNT_KEY,dir_mode=0777,file_mode=0777,serverino

echo 'Mount now to avoid a reboot'
sudo mount -a


echo 'Add folder paths as environment variables'
echo "" | sudo tee -a "$HOME/.bashrc" > /dev/null
echo "#RETRO-CLOUD: The environment variables below are from virtual-machine/mount-az-share.sh" | sudo tee -a "$HOME/.bashrc" > /dev/null
# Note: RETROCLOUD_VM_SHARE and RETROCLOUD_VM_MOUNT_POINT are currently the same.
echo "export RETROCLOUD_VM_MOUNT_POINT=$mntPath" | sudo tee -a "$HOME/.bashrc" > /dev/null
echo "export RETROCLOUD_AZ_CREDENTIALS=$smbCredentialFile" | sudo tee -a "$HOME/.bashrc" > /dev/null

echo 'Done!'
echo "File share mounted on $mntPath"
