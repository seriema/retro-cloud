#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

#
# Elite, for multiple platforms
# Available as freeware at http://www.elitehomepage.org/game.htm

download_elite () {
    local platform=$1
    local filename=$2

    echo "Downloading elite for $platform"

    # Copy a freeware game from the makers website
    curl -sSOL "http://www.elitehomepage.org/archive/a/${filename}.zip"

    # Move it and give it a better name otherwise the scrapers won't find it
    mkdir -p "$HOME/RetroPie/roms/$platform"
    # cp instead of mv because the destination is another file system: https://unix.stackexchange.com/a/131181/401446
    cp "$filename.zip" "$_/elite.zip"
    rm "$filename.zip"
}

# These are commented out because they weren't detected by EmulationStation
# download_elite amiga      "a8100000" # 332K
# download_elite gb         "b4040900" # 13K, demo
# download_elite genesis    "b4020010" # 222K, demo
download_elite nes        "b7120500" # 82K
download_elite zxspectrum "a5100010" # 28, demo
