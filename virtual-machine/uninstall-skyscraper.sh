#!/bin/bash
# https://github.com/muldjord/skyscraper#how-to-uninstall-skyscraper

# Abort on error
set -e
# Error if variable is unset
set -u

echo 'Uninstalling Skyscraper'
cd "$HOME/skysource"
sudo make uninstall
cd -
rm -Rf "$HOME/skysource"
rm -Rf "$HOME/.skyscraper"

echo 'Done!'
