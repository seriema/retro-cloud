#!/bin/bash
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-6#raspbian

###################################
# Delete the extracted PowerShell

rm -rf ~/powershell

# Remove unused apt packages
sudo apt autoremove
