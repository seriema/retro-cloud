#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

echo 'Verify number of roms folders. There is one for each successful emultator installed.'
# Two emulators aren't available on amd64: mame-mame4all, amiga
if [ "$(uname -m)" = 'armv7l' ]; then
    emulators='32';
else
    emulators='30';
fi

if [ ! $(ls ~/RetroPie/roms | wc -l) == $emulators ]; then
    echo "Not enough roms folders. Did an emulator fail to install?"
    echo "These were installed:"
    ls ~/RetroPie/roms
    exit 1
fi

echo 'Verify that there are no builds left. There is one for each failed build.'
[ -z "`find /home/pi/RetroPie-Setup/tmp/build -maxdepth 3 -type f`" ]

echo 'Verify that line endings of all files are LF. Windows uses CRLF which can get copied over by Docker ADD/COPY.'
[ ! "$(grep -r $'\r' * -l)" ]
