#!/bin/bash
# Take a parameter for prefixing the Azure resource group name. It default to the current date to be unique
# yet findable. Useful values could be the build number during CI, or the users unique machine name.
rgPrefix=${1:-''}

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

# If this env var is set then it's running under automation and will skip the prompt.
if [[ "${AZURE_SERVICE_PRINCIPAL_SECRET:-missing}" == "missing" ]]; then
    echo "You will eventually be prompted to log in to Azure."
    echo "1. Log in to https://portal.azure.com on any device to make sure you're ready."
    echo "2. Head to https://www.microsoft.com/devicelogin and be ready to input the code seen during the setup."
    # https://stackoverflow.com/a/1885534
    read -p "Ready to continue [y/N]? " -r
    if [[ ! $REPLY =~ ^y|Y|[yY][eE][sS]$ ]]; then
        [[ "$0" = "${BASH_SOURCE[*]}" ]] && exit 1 || return 1
    fi
fi

echo "SETUP: Install PowerShell"
bash install-ps.sh

echo "SETUP: Run PowerShell scripts to create the Azure resources"
pwsh -executionpolicy bypass -File ".\setup-az.ps1" -rgPrefix "$rgPrefix"

echo "SETUP: Mount remote files"
# Run this in interactive mode, otherwise bash won't load the variables set in ~/.bashrc by the create-vm-share.sh script above.
# https://stackoverflow.com/a/43660876
bash -i mount-vm-share.sh

echo "SETUP: Configure RaspberryPi"
bash -i configure.sh

echo "SETUP: Copy run scripts to user root"
cp -v local/add-scraper-credential.sh "$HOME/add-scraper-credential.sh"
cp -v local/copy-roms-to-file-share.sh "$HOME/copy-roms-to-file-share.sh"
cp -v local/run-scraper.sh "$HOME/run-scraper.sh"
cp -v local/setup-vm.sh "$HOME/setup-vm.sh"
cp -v local/ssh-vm.sh "$HOME/ssh-vm.sh"
# Make them executable
chmod +x "$HOME/add-scraper-credential.sh"
chmod +x "$HOME/copy-roms-to-file-share.sh"
chmod +x "$HOME/run-scraper.sh"
chmod +x "$HOME/setup-vm.sh"
chmod +x "$HOME/ssh-vm.sh"

echo "SETUP: Done!"

echo "SETUP: Note, you need to load the environment variables! Start a new interactive shell with 'bash -i'."
