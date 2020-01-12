#!/bin/bash
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-6#raspbian

# Abort on error
set -e
# Error if variable is unset
set -u

if [ -e ~/powershell/pwsh ]; then
    echo "PowerShell (pwsh) is already installed."
    exit 0
fi

###################################
# Prerequisites

# Update package lists
sudo apt-get update

# Install libunwind8 and libssl1.0
# Regex is used to ensure that we do not install libssl1.0-dev, as it is a variant that is not required
sudo apt-get install '^libssl1.0.[0-9]$' libunwind8 -y

###################################
# Download and extract PowerShell

# Grab the latest tar.gz
wget https://github.com/PowerShell/PowerShell/releases/download/v6.2.0/powershell-6.2.0-linux-arm32.tar.gz

# Make folder to put powershell
mkdir ~/powershell

# Unpack the tar.gz file
tar -xvf ./powershell-6.2.0-linux-arm32.tar.gz -C ~/powershell

# Remove tar ball
rm ./powershell-6.2.0-linux-arm32.tar.gz

# Create a symbolic link
sudo ln -s ~/powershell/pwsh /usr/bin/pwsh

echo 'To start PowerShell run: pwsh'
