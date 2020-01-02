#!/bin/bash
# https://github.com/muldjord/skyscraper#how-to-uninstall-skyscraper

echo 'Uninstalling Skyscraper'
cd "$HOME/skysource"
sudo make uninstall
cd -
rm -Rf "$HOME/skysource"
rm -Rf "$HOME/.skyscraper"

echo 'Done!'
