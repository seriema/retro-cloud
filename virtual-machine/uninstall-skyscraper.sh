#!/bin/bash
# https://github.com/muldjord/skyscraper#how-to-uninstall-skyscraper

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

echo 'Uninstalling Skyscraper'
docker image rm seriema/retro-cloud:scraper-bin
sudo rm /usr/bin/Skyscraper
rm -Rf "$HOME/.skyscraper"

echo 'Uninstalling Docker, including images, containers, etc'
sudo apt-get purge docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker

echo 'Done!'
