#!/bin/bash
# https://github.com/muldjord/skyscraper#download-compile-and-install

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
# Run Skyscraper to force it to create the ~/.skyscraper folder with initial content.
Skyscraper -v > /dev/null
cp .skyscraper/config.ini "$HOME/.skyscraper/config.ini"

# TODO: copied from mount-share.sh
mntPath="/mnt/$storageAccountName/$fileShareName"
gamelists="$mntPath/output/gamelists"
downloadedMedia="$mntPath/output/downloaded_media"
cache="$mntPath/cache"
# TODO: Temp roms folder
roms="$HOME/tmp/roms"
sed -i -e "s+RETROCLOUD_INPUTFOLDER+$roms+g" "$HOME/.skyscraper/config.ini"
sed -i -e "s+RETROCLOUD_GAMELISTFOLDER+$gamelists+g" "$HOME/.skyscraper/config.ini"
sed -i -e "s+RETROCLOUD_MEDIAFOLDER+$downloadedMedia+g" "$HOME/.skyscraper/config.ini"
sed -i -e "s+RETROCLOUD_CACHEFOLDER+$cache+g" "$HOME/.skyscraper/config.ini"

echo 'Done!'
