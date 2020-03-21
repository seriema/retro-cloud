#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

echo 'Verify number of roms folders. There is one for each successful emultator installed.'
if [ ! $(ls ~/RetroPie/roms | wc -l) == '30' ]; then
    echo "Not enough roms folders. Did an emulator fail to install?"
    echo "These were installed:"
    ls ~/RetroPie/roms
    exit 1
fi

echo 'Verify that there are no builds left. There is one for each failed build.'
[ -z "`find /home/pi/RetroPie-Setup/tmp/build -maxdepth 3 -type f`" ]
