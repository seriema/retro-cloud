#!/bin/bash -i

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

platforms=(
    3do
    amiga
    amstradcpc
    apple2
    arcade
    arcadia
    astrocde
    atari800
    atari2600
    atari5200
    atari7800
    atarijaguar
    atarilynx
    atarist
    c16
    c64
    c128
    coco
    coleco
    daphne
    dragon32
    dreamcast
    fba
    fds
    gameandwatch
    gamegear
    gb
    gba
    gbc
    gc
    genesis
    intellivision
    mame-advmame
    mame-libretro
    mame-mame4all
    mastersystem
    megacd
    megadrive
    msx
    n64
    nds
    neogeo
    nes
    ngp
    ngpc
    oric
    pc
    pc88
    pc98
    pcfx
    pcengine
    pokemini
    ports
    ps2
    psp
    psx
    saturn
    scummvm
    sega32x
    segacd
    sg-1000
    snes
    steam
    ti99
    trs-80
    vectrex
    vic20
    videopac
    virtualboy
    wii
    wonderswan
    wonderswancolor
    x68000
    x1
    zmachine
    zx81
    zxspectrum
)

modules=(
    screenscraper
    thegamesdb
    # arcadedb - Only arcade games
    openretro
    # mobygames - rate limit, last resort
    # igdb - not good yet
    # worldofspectrum - only ZX Spectrum
    # esgamelist - DO NOT USE. it grabs the local already generated files
    # import - Not used, yet. For custom overrides.
)

# TODO: Use --startat to avoid starting from zero?
echo 'Create cache and generate gamelists and artwork'
for platform in "${platforms[@]}"
do
    # If the are no games for this platform, skip (because starting Skyscraper for no games is really slow)
    if ! [ -d "$RETROCLOUD_VM_ROMS/$platform" ]; then
        echo "No games found for $platform. Skipping."
        continue
    fi

    echo "Building cache for $platform"

    # "arcadedb" only has MAME games
    if [[ $platform == *"mame"* ]]; then
        Skyscraper -p "$platform" -s 'arcadedb'
    fi

    # TODO: If there are no games found, run the "screenscraper" module again but with the --unpack flag?

    for module in "${modules[@]}"
    do
        Skyscraper -p "$platform" -s "$module"
    done

    echo "Generating gamelists and artwork for $platform"
    Skyscraper -p "$platform"

    # This step is needed because the AZ mounted path is reflected in the gamelists, and they're symlinked on the rpi to look local.
    echo "Fixing paths in gamelists for $platform"
    # Need to sudo because Skyscraper creates the gamelists.xml without write access on them.
    sudo sed -i -e "s+$RETROCLOUD_VM_ROMS+/home/pi/RetroPie/roms+g" "$RETROCLOUD_VM_GAMELISTS/$platform/gamelist.xml"
    sudo sed -i -e "s+$RETROCLOUD_VM_DOWNLOADEDMEDIA+/home/pi/.emulationstation/downloaded_media+g" "$RETROCLOUD_VM_GAMELISTS/$platform/gamelist.xml"
done
