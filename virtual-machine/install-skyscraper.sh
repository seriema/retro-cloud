#!/bin/bash
# https://github.com/muldjord/skyscraper#download-compile-and-install

# Abort on error
set -e
# Error if variable is unset
set -u

echo 'Install Prerequisites'
sudo apt-get update
# This is over 500mb!
sudo apt-get install build-essential qt5-default -y

echo 'Install Skyscraper'
mkdir -p "$HOME/skysource"
cd "$HOME/skysource"
wget -q -O - https://raw.githubusercontent.com/muldjord/skyscraper/master/update_skyscraper.sh | bash
cd -

echo 'Configure Skyscraper'
# ~/.skyscraper is created when Skyscraper runs the first time but we need it now.
mkdir -p "$HOME/.skyscraper"
cp .skyscraper/config.ini "$HOME/.skyscraper/config.ini"

sed -i -e "s+RETROCLOUD_INPUTFOLDER+$RETROCLOUD_ROMS+g" "$HOME/.skyscraper/config.ini"
sed -i -e "s+RETROCLOUD_GAMELISTFOLDER+$RETROCLOUD_SKYSCRAPER_GAMELISTFOLDER+g" "$HOME/.skyscraper/config.ini"
sed -i -e "s+RETROCLOUD_MEDIAFOLDER+$RETROCLOUD_SKYSCRAPER_MEDIAFOLDER+g" "$HOME/.skyscraper/config.ini"
sed -i -e "s+RETROCLOUD_CACHEFOLDER+$RETROCLOUD_SKYSCRAPER_CACHEFOLDER+g" "$HOME/.skyscraper/config.ini"

echo 'Done!'
