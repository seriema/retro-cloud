#!/bin/bash
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7#raspbian

# Abort on error, and error if variable is unset
set -eu

###################################
# Delete the PowerShell installation

# Remove symbolic link
# https://serverfault.com/a/38817
sudo rm -f /usr/bin/pwsh

# Delete the PowerShell files
rm -rf ~/powershell

# Remove unused apt packages
sudo apt autoremove
