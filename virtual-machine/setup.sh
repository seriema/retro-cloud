#!/bin/bash

# Abort on error
set -e
# Error if variable is unset
set -u

echo "SETUP: Download scripts to ~/tmp/retro-cloud"
mkdir -p "$HOME/tmp/retro-cloud"
cd "$HOME/tmp/retro-cloud"
branch=vm
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/install-skyscraper.sh"
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/create-vm-share.sh"
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/mount-az-share.sh"
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/local/run-skyscraper.sh"
# TODO: This should be installed from the install-skyscraper script instead but the branch name in the URL needs to stay in sync here.
mkdir .skyscraper
wget -q -O ".skyscraper/config.ini" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/.skyscraper/config.ini"

echo "SETUP: Mount Azure File Share"
bash mount-az-share.sh

echo "SETUP: Create share for Raspberry Pi"
# Run this in interactive mode, otherwise bash won't load the variables set in ~/.bashrc by the create-vm-share.sh script above.
# https://stackoverflow.com/a/43660876
bash -i create-vm-share.sh

echo "SETUP: Install Skyscraper"
# Run this in interactive mode, otherwise bash won't load the variables set in ~/.bashrc by the create-vm-share.sh script above.
# https://stackoverflow.com/a/43660876
bash -i install-skyscraper.sh

echo "SETUP: Delete ~/tmp/retro-cloud"
cd
rm -r "$HOME/tmp/retro-cloud"

echo "SETUP: Done!"

echo "Run the scraper with: ./run-skyscraper.sh"
