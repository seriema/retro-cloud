#!/bin/bash
# https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux#mounting-azure-file-share

# Abort on error
set -e

echo 'Install Prerequisites'

sudo apt-get update
sudo apt-get install cifs-utils


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
else 
    echo "The credential file $smbCredentialFile already exists, and was not modified."
fi

echo 'Change permissions on the credential file so only root can read or modify the password file.'
sudo chmod 600 $smbCredentialFile

echo 'Append the mount to /etc/fstab'
if [ -z "$(grep $smbPath\ $mntPath /etc/fstab)" ]; then
    echo "# RETRO-CLOUD: The changes below were made by retro-cloud" | sudo tee -a /etc/fstab > /dev/null
    # To the right is the original, and the below is what I made some time ago: echo "$smbPath $mntPath cifs nofail,vers=3.0,credentials=$smbCredentialFile,serverino" | sudo tee -a /etc/fstab > /dev/null
    echo "$smbPath $mntPath cifs _netdev,nofail,vers=3.0,credentials=$smbCredentialFile,dir_mode=0777,file_mode=0777,serverino" | sudo tee -a /etc/fstab > /dev/null
else
    echo "/etc/fstab was not modified to avoid conflicting entries as this Azure file share was already present. You may want to double check /etc/fstab to ensure the configuration is as desired."
    echo "Aborting to avoid issues"
    exit 0
fi

echo 'Mount right away'
sudo mount -a


echo 'Create Skyscraper output folders to be mounted.'
gamelists="$mntPath/output/gamelists"
downloadedMedia="$mntPath/output/downloaded_media"
emulationstation="$HOME/.emulationstation"

sudo mkdir -p "$gamelists"
sudo mkdir -p "$downloadedMedia"
mkdir "$emulationstation"

echo 'Symlink the folders to look like emulationstation' # but this doesn't work?!
ln -s "$gamelists" "$emulationstation"
ln -s "$downloadedMedia" "$emulationstation"


echo 'Done!'
echo "File share mounted on $mntPath"
echo "Symlinked folders to $emulationstation"
