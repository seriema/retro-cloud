#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

# Copy a tiny (82K) freeware game from the makers website
curl -fOL http://www.elitehomepage.org/archive/a/b7120500.zip

# Move it and give it a better name otherwise the scrapers won't find it
sudo mkdir -p "$RETROCLOUD_VM_SHARE/RetroPie/roms/nes"
sudo mv "b7120500.zip" "$_/elite.zip"
