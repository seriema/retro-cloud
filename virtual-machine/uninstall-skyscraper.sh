#!/bin/bash
# https://github.com/muldjord/skyscraper#how-to-uninstall-skyscraper

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

echo 'Uninstalling Skyscraper'
cd "$HOME/skysource"
sudo make uninstall
cd -
rm -Rf "$HOME/skysource"
rm -Rf "$HOME/.skyscraper"

echo 'Done!'
