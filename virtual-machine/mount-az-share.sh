#!/bin/bash
# https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux#mounting-azure-file-share

# Abort on error
set -e
# Error if variable is unset
set -u

echo 'Install Prerequisites'

sudo apt-get update > /dev/null
sudo apt-get install cifs-utils > /dev/null


echo 'Create a persistent mount point for the Azure file share with /etc/fstab'

echo 'Create a folder for the mount point'
mntPath="/mnt/$storageAccountName/$fileShareName"
sudo mkdir -p $mntPath

echo 'Create a credential file to store the username and password for the file share.'
if [ ! -d "/etc/smbcredentials" ]; then
    sudo mkdir "/etc/smbcredentials"
fi

smbCredentialFile="/etc/smbcredentials/$storageAccountName.cred"
if [ ! -f $smbCredentialFile ]; then
    echo "username=$storageAccountName" | sudo tee $smbCredentialFile > /dev/null
    echo "password=$storageAccountKey" | sudo tee -a $smbCredentialFile > /dev/null
    echo "Credential file $smbCredentialFile created"

    echo 'Change permissions on the credential file so only root can read or modify the password file.'
    sudo chmod 600 $smbCredentialFile
else 
    echo "The credential file $smbCredentialFile already exists, and was not modified."
fi

echo 'Create a persistent mount point in /etc/fstab'
if [ -z "$(grep $smbPath\ $mntPath /etc/fstab)" ]; then
    echo "# RETRO-CLOUD: The changes below were made by retro-cloud" | sudo tee -a /etc/fstab > /dev/null
    echo "$smbPath $mntPath cifs _netdev,nofail,vers=3.0,credentials=$smbCredentialFile,dir_mode=0777,file_mode=0777,serverino" | sudo tee -a /etc/fstab > /dev/null
else
    echo "/etc/fstab was not modified to avoid conflicting entries as this Azure file share was already present. You may want to double check /etc/fstab to ensure the configuration is as desired."
    echo "Aborting to avoid issues"
    exit 0
fi

echo 'Mount now to avoid a reboot'
sudo mount -a


echo 'Create Skyscraper output folders.'
gamelists="$mntPath/output/gamelists"
downloadedMedia="$mntPath/output/downloaded_media"
cache="$mntPath/cache"

sudo mkdir -p "$gamelists"
sudo mkdir -p "$downloadedMedia"
sudo mkdir -p "$cache"

echo 'Add folder paths as environment variables'
echo "" | sudo tee -a "$HOME/.bashrc" > /dev/null
echo "#RETRO-CLOUD: The environment variables below are from virtual-machine/mount-az-share.sh" | sudo tee -a "$HOME/.bashrc" > /dev/null
echo "export RETROCLOUD_AZ_MOUNT=$mntPath" | sudo tee -a "$HOME/.bashrc" > /dev/null
echo "export RETROCLOUD_AZ_CREDENTIALS=$smbCredentialFile" | sudo tee -a "$HOME/.bashrc" > /dev/null
echo "export RETROCLOUD_SKYSCRAPER_GAMELISTFOLDER=$gamelists" | sudo tee -a "$HOME/.bashrc" > /dev/null
echo "export RETROCLOUD_SKYSCRAPER_MEDIAFOLDER=$downloadedMedia" | sudo tee -a "$HOME/.bashrc" > /dev/null
echo "export RETROCLOUD_SKYSCRAPER_CACHEFOLDER=$cache" | sudo tee -a "$HOME/.bashrc" > /dev/null
# TODO: Mount ROMs share. Using temp roms folder until then.
echo "export RETROCLOUD_ROMS=$HOME/tmp/roms" | sudo tee -a "$HOME/.bashrc" > /dev/null

echo 'Done!'
echo "File share mounted on $mntPath"
