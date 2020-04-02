#!/bin/bash
# https://github.com/muldjord/skyscraper#updating-skyscraper

# Abort on error
set -e
# Error if variable is unset
set -u

echo 'Updating Skyscraper'
cd "$HOME/skysource"
./update_skyscraper.sh
cd -

echo 'Done!'
