#!/bin/bash

# Abort on error, error if variable is unset, and enable debug output
set -eux

echo 'Verify number of roms folders. There is one for each successful emultator installed.'
# Added when RetroPie-Setup was failing silently and not installing all emulators.
# Note: Export a new list with: $ ls -m ~/RetroPie/roms
if [[ $(uname -m) = 'armv7l' ]]; then
    emulators="amiga, amstradcpc, arcade, atari2600, atari5200, atari7800, atari800, atarilynx, fba, fds, gamegear, gb, gba, gbc, genesis, mame-libretro, mame-mame4all, mastersystem, megadrive, n64, neogeo, nes, ngp, ngpc, pcengine, psx, sega32x, segacd, sg-1000, snes, vectrex, zxspectrum";
else
    # Two emulators aren't available on amd64: mame-mame4all, amiga
    emulators="amstradcpc, arcade, atari2600, atari5200, atari7800, atari800, atarilynx, fba, fds, gamegear, gb, gba, gbc, genesis, mame-libretro, mastersystem, megadrive, n64, neogeo, nes, ngp, ngpc, pcengine, psx, sega32x, segacd, sg-1000, snes, vectrex, zxspectrum";
fi
[[ -z $(echo $(echo "$emulators" | tr ',' '\n') $(ls -1 ~/RetroPie/roms) | tr ' ' '\n' | sort | uniq -u) ]]

echo 'Verify that there are no builds left. There is one for each failed build.'
# Added when RetroPie-Setup was failing silently and not installing all emulators.
[[ -z $(find /home/pi/RetroPie-Setup/tmp/build -maxdepth 3 -type f) ]]

echo 'Verify that line endings of all files are LF. Windows uses CRLF which can get copied over by Docker ADD/COPY.'
# Added when running the container would throw '\r' parse errors when the users bash profile. Despite
# .gitattribute set to checkout all files in docker/rpi as LF it could still check them out as CRLF,
# and Docker has a tendency to use the host line endings when copying files.
# Note: The Dockerfile no longer copies bash files because COPY constantly invalidates the cache, forcing
# unnecessary rebuilds that take 30-60 minutes locally and 2-3 hours on Docker Hub. The test is kept
# as a regression test for future changes to the Dockerfile.
[[ -z $(grep -r $'\r' * -l) ]]
