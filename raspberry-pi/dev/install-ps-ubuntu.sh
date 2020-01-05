#!/bin/bash

# The magic commands around "dpkg" and "apt-get" are due to the dpkg fork in ubuntu that is really noisy:
# https://peteris.rocks/blog/quiet-and-unattended-installation-with-apt-get/

# Download the Microsoft repository GPG keys
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb

# Register the Microsoft repository GPG keys
# sudo dpkg -i packages-microsoft-prod.deb
sudo DEBIAN_FRONTEND=noninteractive dpkg -i packages-microsoft-prod.deb

# Update the list of products
# sudo apt-get update -q
sudo DEBIAN_FRONTEND=noninteractive apt-get update < /dev/null > /dev/null

# Enable the "universe" repositories
# sudo add-apt-repository universe
sudo DEBIAN_FRONTEND=noninteractive add-apt-repository universe < /dev/null > /dev/null

# Install PowerShell
# sudo apt-get install -y -q powershell
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y powershell < /dev/null > /dev/null

echo 'To start PowerShell run: pwsh'
