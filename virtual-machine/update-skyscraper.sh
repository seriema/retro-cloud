#!/bin/bash
# https://github.com/muldjord/skyscraper#updating-skyscraper

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

echo 'Updating Skyscraper'
cd "$HOME/skysource"
./update_skyscraper.sh
cd -

echo 'Done!'
