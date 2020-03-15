#!/bin/bash
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7#raspbian

# Abort on error, and error if variable is unset
set -eu

###################################
# Abort if PowerShell already exists.

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

if [ $(uname -m) == 'x86_64' ]; then
    # Only used during development in a Azure VM or Docker, both based on Ubuntu.
    arch=x64
else
    # Assume a Raspberry Pi
    arch=arm32
fi

# Grab the latest tar.gz
wget -nv "https://github.com/PowerShell/PowerShell/releases/download/v7.0.0/powershell-7.0.0-linux-$arch.tar.gz"

# Make folder to put powershell
mkdir ~/powershell

# Unpack the tar.gz file
tar -zxvf "./powershell-7.0.0-linux-$arch.tar.gz" -C ~/powershell

# Set execute permissions
chmod +x ~/powershell/pwsh

# Remove tar ball
rm "./powershell-7.0.0-linux-$arch.tar.gz"

# Create a symbolic link
sudo ln -s ~/powershell/pwsh /usr/bin/pwsh

echo 'To start PowerShell run: pwsh'
