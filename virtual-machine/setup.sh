#!/bin/bash

# Abort on error
set -e
# Error if variable is unset
set -u

echo "SETUP: Download scripts to ~/tmp/retro-cloud"
mkdir -p "$HOME/tmp/retro-cloud"
cd "$HOME/tmp/retro-cloud"
branch=vm
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/.skyscraper/config.ini"
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/install-skyscraper.sh"
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/create-vm-share.sh"
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/mount-az-share.sh"
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/run-skyscraper.sh"

echo "SETUP: Mount Azure File Share"
bash mount-az-share.sh

echo "SETUP: Install Skyscraper"
bash install-skyscraper.sh

echo "SETUP: Create share for Raspberry Pi"
bash create-vm-share.sh

echo "SETUP: Delete ~/tmp/retro-cloud"
cd
rm -r "$HOME/tmp/retro-cloud"

echo "SETUP: Done!"

echo "SETUP: Scrape ROMS and build gamelists"
bash run-skyscraper.sh