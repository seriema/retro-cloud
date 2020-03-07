#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

echo "SETUP: Install PowerShell"
if cat /etc/os-release | grep -wq 'NAME="Ubuntu"'; then
    # Only used during development and is used in a Azure VM or Docker.
    bash dev/install-ps-ubuntu.sh
else
    bash install-ps.sh
fi

echo "SETUP: Run PowerShell scripts to create the Azure resources"
pwsh -executionpolicy bypass -File ".\setup-az.ps1"

echo "SETUP: Mount remote files"
# Run this in interactive mode, otherwise bash won't load the variables set in ~/.bashrc by the create-vm-share.sh script above.
# https://stackoverflow.com/a/43660876
bash -i mount-vm-share.sh

echo "SETUP: Copy run scripts to user root"
cp local/run-scraper.sh "$HOME/run-scraper.sh"
cp local/setup-vm.sh "$HOME/setup-vm.sh"
cp local/ssh-vm.sh "$HOME/ssh-vm.sh"

echo "SETUP: Done!"
