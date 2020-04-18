#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

echo 'Copy a tiny (82K) freeware game from the makers website'
curl -fOL http://www.elitehomepage.org/archive/a/b7120500.zip

echo 'Move it and give it a better name so the scrapers find it'
sudo mkdir -p "$RETROCLOUD_VM_SHARE/RetroPie/roms/nes"
sudo mv -v "b7120500.zip" "$_/elite.zip"
