#!/bin/bash
# Script takes optional parameter for branch name or commit hash.
branch=${1:-master}

# Abort on error, and error if variable is unset
set -eu

echo "SETUP: Download scripts to ~/retro-cloud-setup"
mkdir -p "$HOME/retro-cloud-setup"
cd "$HOME/retro-cloud-setup"
curl -fOL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/create-vm.ps1"
curl -fOL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/install-az-module.ps1"
curl -fOL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/install-ps.sh"
curl -fOL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/mount-vm-share.sh"
curl -fOL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/setup-az.ps1"
curl -fOL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/setup.sh"
curl -fOL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/teardown.sh"
curl -fOL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/teardown-az.ps1"
mkdir -p "local"
curl -fL -o "local/add-scraper-credential.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/local/add-scraper-credential.sh"
curl -fL -o "local/run-scraper.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/local/run-scraper.sh"
curl -fL -o "local/setup-vm.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/local/setup-vm.sh"
curl -fL -o "local/ssh-vm.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/raspberry-pi/local/ssh-vm.sh"

echo "SETUP: Run setup.sh"
bash setup.sh

echo "SETUP: Done!"
