#!/bin/bash
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7#raspbian

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

###################################
# Delete the PowerShell installation

# Remove symbolic link
# https://serverfault.com/a/38817
sudo rm -f /usr/bin/pwsh

# Delete the PowerShell files
sudo rm -rf /opt/microsoft/powershell/7

# Remove unused apt packages
sudo apt autoremove
