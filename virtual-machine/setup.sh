#!/bin/bash

echo "SETUP: Download scripts to ~/tmp/retro-cloud"
mkdir -p "$HOME/tmp/retro-cloud"
cd "$HOME/tmp/retro-cloud"
branch=vm
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/.skyscraper/config.ini"
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/install-skyscraper.sh"
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/mount-share.sh"
wget -q "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/run-skyscraper.sh"

echo "SETUP: Mount Azure File Share"
bash ./mount-share.sh

echo "SETUP: Install Skyscraper"
bash ./install-skyscraper.sh

echo "SETUP: Delete ~/tmp/retro-cloud"
cd
rm -r "$HOME/tmp/retro-cloud"

echo "SETUP: Done!"

echo "SETUP: Scrape ROMS and build gamelists"
bash run-skyscraper.sh