#!/bin/bash
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7#installation---binary-archives

# Abort on error, and error if variable is unset
set -eu

target="/opt/microsoft/powershell/7"

###################################
# Abort if PowerShell already exists.

if [ -e "$target/pwsh" ]; then
    echo "PowerShell (pwsh) is already installed."
    exit 0
fi

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
sudo mkdir -p "$target"

# Unpack the tar.gz file
sudo tar -zxvf "./powershell-7.0.0-linux-$arch.tar.gz" -C "$target"

# Set execute permissions
sudo chmod +x "$target/pwsh"

# Remove tar ball
rm "./powershell-7.0.0-linux-$arch.tar.gz"

# Create a symbolic link
sudo ln -s "$target/pwsh" /usr/bin/pwsh

echo 'To start PowerShell run: pwsh'
