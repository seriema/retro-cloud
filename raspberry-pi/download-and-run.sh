#!/bin/bash
# Script takes optional parameter for branch name or commit hash.
branch=${1:-develop}

# Abort on error, and error if variable is unset
set -eu

echo "SETUP: Download scripts to ~/retro-cloud-setup"
mkdir -p "$HOME/retro-cloud-setup"
cd "$HOME/retro-cloud-setup"
curl -OL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/create-vm.ps1"
curl -OL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/install-az-module.ps1"
curl -OL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/install-ps.sh"
curl -OL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/mount-vm-share.sh"
curl -OL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/setup-az.ps1"
curl -OL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/setup.sh"
mkdir -p "local"
curl -L -o "local/run-scraper.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/local/run-scraper.sh"
curl -L -o "local/setup-vm.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/local/setup-vm.sh"
curl -L -o "local/ssh-vm.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/local/ssh-vm.sh"

echo "SETUP: Run setup.sh"
bash setup.sh

echo "SETUP: Done!"
