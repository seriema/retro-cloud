#!/bin/bash
# Script takes optional parameter for branch name or commit hash.
branch=${1:-master}

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

if [[ -d /home/pi/RetroPie-Setup ]]; then
    echo "Are you running this script on the Raspberry Pi? It should be run from within the VM.";
    echo "SSH to the VM with 'bash -i ~/ssh-vm.sh' and then call this script again.";
    echo "Or run 'bash -i ~/setup-vm.sh' that will do it for you.";
    exit 1
fi

echo "SETUP: Download scripts to ~/retro-cloud-setup"
mkdir -p "$HOME/retro-cloud-setup"
cd "$HOME/retro-cloud-setup"
curl -fOL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/install-skyscraper.sh"
curl -fOL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/create-vm-share.sh"
curl -fOL "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/mount-az-share.sh"
# TODO: This should be installed from the install-skyscraper script instead but the branch name in the URL needs to stay in sync here.
mkdir .skyscraper
curl -fL -o ".skyscraper/config.ini" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/.skyscraper/config.ini"
mkdir "local"
curl -fL -o "local/add-scraper-credential.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/local/add-scraper-credential.sh"
curl -fL -o "local/run-skyscraper.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/local/run-skyscraper.sh"
mkdir "dev"
curl -fL -o "dev/list-path.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/shared/list-path.sh"
curl -fL -o "dev/test-copy-rom.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/dev/test-copy-rom.sh"
curl -fL -o "dev/test-gamelist-screenscraper-failed.xml" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/dev/test-gamelist-screenscraper-failed.xml"
curl -fL -o "dev/test-gamelist.sh" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/dev/test-gamelist.sh"
curl -fL -o "dev/test-gamelist.xml" "https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/dev/test-gamelist.xml"

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

echo "SETUP: Done!"

echo "Run the scraper with: ./run-skyscraper.sh"
