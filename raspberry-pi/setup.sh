#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

echo "SETUP: Install PowerShell"
bash install-ps.sh

echo "SETUP: Run PowerShell scripts to create the Azure resources"
pwsh -executionpolicy bypass -File ".\setup-az.ps1"

echo "SETUP: Mount remote files"
# Run this in interactive mode, otherwise bash won't load the variables set in ~/.bashrc by the create-vm-share.sh script above.
# https://stackoverflow.com/a/43660876
bash -i mount-vm-share.sh

echo "SETUP: Copy run scripts to user root"
cp -v local/run-scraper.sh "$HOME/run-scraper.sh"
cp -v local/setup-vm.sh "$HOME/setup-vm.sh"
cp -v local/ssh-vm.sh "$HOME/ssh-vm.sh"

echo "SETUP: Done!"

echo 'SETUP: Note, you need to load the environment variables! Start a new interactive shell with `bash -i`.'
