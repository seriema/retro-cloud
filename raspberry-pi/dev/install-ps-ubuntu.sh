#!/bin/bash

# The magic commands around "dpkg" and "apt-get" are due to the dpkg fork in ubuntu that is really noisy:
# https://peteris.rocks/blog/quiet-and-unattended-installation-with-apt-get/

# Download the Microsoft repository GPG keys
wget -nv https://github.com/PowerShell/PowerShell/releases/download/v7.0.0/powershell_7.0.0-1.ubuntu.18.04_amd64.deb

# Note: The dpkg -i command fails with unmet dependencies. The next command, apt-get install -f resolves these issues then finishes configuring the PowerShell package.
sudo dpkg -i powershell_7.0.0-1.ubuntu.18.04_amd64.deb
sudo apt-get install -f -y

# Cleanup
rm powershell_7.0.0-1.ubuntu.18.04_amd64.deb

echo 'To start PowerShell run: pwsh'
