#!/bin/bash
# https://github.com/muldjord/skyscraper#updating-skyscraper

echo 'Updating Skyscraper'
cd "$HOME/skysource"
./update_skyscraper.sh
cd -

echo 'Done!'
