#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

if diff "$RETROCLOUD_VM_SHARE/.emulationstation/gamelists/scummvm/gamelist.xml" ~/tmp/test-gamelist.xml
then
    echo "Scraping was successful"
else
    echo "Scraping failed somehow because the gamelist isn't as expected. See details above."
fi
