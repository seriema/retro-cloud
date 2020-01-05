#!/bin/bash

# Abort on error
set -e
# Error if variable is unset
set -u

echo "SETUP: Download scripts to ~/tmp/retro-cloud"
mkdir -p "$HOME/tmp/retro-cloud"
cd "$HOME/tmp/retro-cloud"
wget -q https://raw.githubusercontent.com/seriema/retro-cloud/develop/raspberry-pi/create-vm.ps1
wget -q https://raw.githubusercontent.com/seriema/retro-cloud/develop/raspberry-pi/install-az-module.ps1
wget -q https://raw.githubusercontent.com/seriema/retro-cloud/develop/raspberry-pi/install-ps.sh
wget -q https://raw.githubusercontent.com/seriema/retro-cloud/develop/raspberry-pi/setup-az.ps1

echo "SETUP: Install PowerShell"
if cat /etc/os-release | grep -wq 'NAME="Ubuntu"'; then
    # Only used during development, for recursively creating VM's with resources. Convenient until I have a rpi Docker setup.
    wget -q https://raw.githubusercontent.com/seriema/retro-cloud/develop/raspberry-pi/dev/install-ps-ubuntu.sh
    bash install-ps-ubuntu.sh
else
    bash install-ps.sh
fi


echo "SETUP: Run PowerShell scripts to create the Azure resources"
pwsh -executionpolicy bypass -File ".\setup-az.ps1"

echo "SETUP: Mount remote files"
# Run this in interactive mode, otherwise bash won't load the variables set in ~/.bashrc by the create-vm-share.sh script above.
# https://stackoverflow.com/a/43660876
bash -i mount-vm-share.sh

echo "SETUP: Delete ~/tmp/retro-cloud"
cd -
rm -r "$HOME/tmp/retro-cloud"

echo "SETUP: Done!"
