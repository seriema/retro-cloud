#!/bin/bash
# https://github.com/muldjord/skyscraper#download-compile-and-install

# Abort on error
set -e
# Error if variable is unset
set -u

echo 'Install Prerequisites (over 500mb, so it takes a while)'
sudo apt-get update
# This is over 500mb!
sudo apt-get install build-essential qt5-default -y

echo 'Install Skyscraper (takes a while)'
mkdir -p "$HOME/skysource"
cd "$HOME/skysource"
curl -fL https://raw.githubusercontent.com/muldjord/skyscraper/master/update_skyscraper.sh | bash
cd -

echo 'Configure Skyscraper'
# ~/.skyscraper is created when Skyscraper runs the first time but we need it now.
mkdir -p "$HOME/.skyscraper"
cp -v .skyscraper/config.ini "$HOME/.skyscraper/config.ini"

# If these variables aren't available, make sure this script is running in interactive mode (https://stackoverflow.com/a/43660876) and mount-az-share.sh.
sed -i -e "s+RETROCLOUD_INPUTFOLDER+$RETROCLOUD_VM_ROMS+g" "$HOME/.skyscraper/config.ini"
sed -i -e "s+RETROCLOUD_GAMELISTFOLDER+$RETROCLOUD_VM_GAMELISTS+g" "$HOME/.skyscraper/config.ini"
sed -i -e "s+RETROCLOUD_MEDIAFOLDER+$RETROCLOUD_VM_DOWNLOADEDMEDIA+g" "$HOME/.skyscraper/config.ini"
sed -i -e "s+RETROCLOUD_CACHEFOLDER+$RETROCLOUD_VM_SKYSCRAPER_CACHE+g" "$HOME/.skyscraper/config.ini"

echo 'Copy run script to user root'
cp -v local/add-scraper-credential.sh "$HOME/add-scraper-credential.sh"
cp -v local/run-skyscraper.sh "$HOME/run-skyscraper.sh"
# Make it executable
chmod 777 "$HOME/add-scraper-credential.sh"
chmod 777 "$HOME/run-skyscraper.sh"

echo 'Done!'
