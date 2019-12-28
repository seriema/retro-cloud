#!/bin/bash
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-6#raspbian

###################################
# Delete the PowerShell installation

# Remove symbolic link
# https://serverfault.com/a/38817
sudo rm /usr/bin/pwsh

# Delete all the 
rm -rf ~/powershell

# Remove unused apt packages
sudo apt autoremove
