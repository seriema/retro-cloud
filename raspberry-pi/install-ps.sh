#!/bin/bash
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7#installation---binary-archives

# Abort on error, and error if variable is unset
set -eu

target="/opt/microsoft/powershell/7"

echo 'Install PowerShell'

###################################
# Abort if PowerShell already exists.

if [ -e "$target/pwsh" ]; then
    echo "PowerShell (pwsh) is already installed."
    exit 0
fi

###################################
# Download and extract PowerShell

if [[ $(uname -m) == 'x86_64' ]]; then
    # Only used during development in a Azure VM or Docker, both based on Ubuntu.
    arch=x64
else
    # Assume a Raspberry Pi
    arch=arm32
fi

echo 'Download the latest tar.gz'
curl -OL "https://github.com/PowerShell/PowerShell/releases/download/v7.0.0/powershell-7.0.0-linux-$arch.tar.gz"

echo "Make folder to put powershell ($target)"
sudo mkdir -p "$target"

echo 'Unpack the tar.gz file'
sudo tar -zxf "./powershell-7.0.0-linux-$arch.tar.gz" -C "$target"

echo 'Set execute permissions'
sudo chmod +x "$target/pwsh"

echo 'Remove tar ball'
rm "./powershell-7.0.0-linux-$arch.tar.gz"

echo 'Create a symbolic link as /usr/bin/pwsh'
sudo ln -s "$target/pwsh" /usr/bin/pwsh

echo 'To start PowerShell run: pwsh'
