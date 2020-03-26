#!/bin/bash

# Abort on error
set -e
# Error if variable is unset
set -u

mntPath="/mnt/$RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME/$RETROCLOUD_AZ_STORAGE_ACCOUNT_KEY"
smbCredentialFile="/etc/smbcredentials/$RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME.cred"
emulationstation="$HOME/.emulationstation"

sudo rm -r -f "$mntPath/output"
rm -r -f "$emulationstation"

sudo umount $mntPath 2> /dev/null

sudo rm -f $smbCredentialFile

sudo rm -r -f $mntPath

sudo sed -i.bak "/RETRO-CLOUD/d" /etc/fstab
sudo sed -i.bak "/$RETROCLOUD_AZ_STORAGE_ACCOUNT_NAME/d" /etc/fstab

echo 'Done!'
