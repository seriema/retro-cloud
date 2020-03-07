#!/bin/bash
# Script takes optional parameter for branch name or commit hash.
branch=${1:-develop}

# Abort on error, and error if variable is unset
set -eu

echo "SETUP: Download scripts to ~/retro-cloud-setup"
mkdir -p "$HOME/retro-cloud-setup"
cd "$HOME/retro-cloud-setup"
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/create-vm.ps1"
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/install-az-module.ps1"
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/install-ps.sh"
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/setup-az.ps1"
mkdir -p "local"
wget -q -O "local/run-scraper.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/local/run-scraper.sh"
wget -q -O "local/setup-vm.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/local/setup-vm.sh"
wget -q -O "local/ssh-vm.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/local/ssh-vm.sh"

wget -q -O "dev/install-ps-ubuntu.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/dev/install-ps-ubuntu.sh"

echo "SETUP: Run setup.sh"
bash setup.sh

echo "SETUP: Done!"
