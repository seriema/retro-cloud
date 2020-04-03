#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

if diff "$RETROCLOUD_VM_SHARE/.emulationstation/gamelists/nes/gamelist.xml" ~/tmp/test-gamelist.xml
then
    echo "Scraping was successful"
    exit 0
fi

echo "Scraping failed somehow because the gamelist isn't as expected. See details above."

echo "This could be due to Screenscraper.fr often having API issues. Trying again with a slimmer XML."
if diff "$RETROCLOUD_VM_SHARE/.emulationstation/gamelists/nes/gamelist.xml" ~/tmp/test-gamelist-screenscraper-failed.xml
then
    echo "Matched. Assuming it was a fluke."
    exit 0
fi

echo "No something's definitely wrong. See details above."
exit 1
