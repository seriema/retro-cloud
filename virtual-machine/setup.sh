#!/bin/bash
# Script takes optional parameter for branch name or commit hash.
branch=${1:-develop}

# Abort on error
set -e
# Error if variable is unset
set -u

if [[ ! -z $(find /home/pi/RetroPie-Setup -maxdepth 1) ]]; then
    echo "Are you running this script on the Raspberry Pi? It should be run from within the VM.";
    echo "SSH to the VM with `bash -i ~/ssh-vm.sh` and then call this script again.";
    echo "Or run `bash -i ~/setup-vm.sh` that will do it for you.";
    exit 1
fi

echo "SETUP: Download scripts to ~/tmp/retro-cloud"
mkdir -p "$HOME/tmp/retro-cloud"
cd "$HOME/tmp/retro-cloud"
curl -OL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/install-skyscraper.sh"
curl -OL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/create-vm-share.sh"
curl -OL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/mount-az-share.sh"
# TODO: This should be installed from the install-skyscraper script instead but the branch name in the URL needs to stay in sync here.
mkdir .skyscraper
curl -L -o ".skyscraper/config.ini" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/.skyscraper/config.ini"
mkdir "local"
curl -L -o "local/run-skyscraper.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/local/run-skyscraper.sh"

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
