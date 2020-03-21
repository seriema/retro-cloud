#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

# Copy a tiny (58K) freeware game from a verified list on ScummVM
curl -OL https://www.scummvm.org/frs/extras/Mystery%20House/MYSTHOUS.zip

# Move it and give it a better name otherwise the scrapers won't find it
sudo mkdir -p "$RETROCLOUD_VM_SHARE/RetroPie/roms/scummvm"
sudo mv "MYSTHOUS.zip" "$_/MysteryHouse.zip"
