#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

# Copy a tiny (58K) freeware game from a verified list on ScummVM
sudo wget -P "$RETROCLOUD_VM_SHARE/RetroPie/roms/scummvm/" -nv https://www.scummvm.org/frs/extras/Mystery%20House/MYSTHOUS.zip
# Give it a better name otherwise the scrapers don't find it
mv "$RETROCLOUD_VM_SHARE/RetroPie/roms/scummvm/MYSTHOUS.zip" "$RETROCLOUD_VM_SHARE/RetroPie/roms/scummvm/MysteryHouse.zip"
