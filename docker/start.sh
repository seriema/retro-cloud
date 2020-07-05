#!/bin/bash
# Accepts a tag (preferably the branch name) as an optional parameter used for the Docker image tag name.
# Note: First time running this you want to run ./raspberry-pi/install-ps.sh. The PowerShell installation will then persist between containers through named volumes.

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

. ./helpers.sh
branch=${1:-"$(getBranch)"}
tag="rc:$branch"

if [[ $(getArch) == "arm32v7" ]]; then # Raspberry Pi
    containerInstance=$(docker container create \
        --env PULSE_SERVER=unix:/run/user/1000/pulse/native \
        --env-file .env \
        --group-add input \
        --group-add video \
        --interactive \
        --privileged \
        --rm \
        --tty \
        `# Mount various volumes that enable devices (e.g. joypad, video, etc) to pass through to the container.` \
        --volume /dev/fb0:/dev/fb0 \
        --volume /dev/input:/dev/input \
        --volume /dev/shm:/dev/shm \
        --volume /dev/snd:/dev/snd \
        --volume /dev/usb:/dev/usb \
        --volume /dev/vchiq:/dev/vchiq \
        --volume /dev/vcio:/dev/vcio \
        --volume /dev/vcsm:/dev/vcsm \
        --volume /opt/vc:/opt/vc \
        --volume /run/user/1000:/run/user/1000 \
        --volume /var/run/dbus/:/var/run/dbus/ \
        `# This stores the PowerShell installation, symlink is created later.` \
        --volume powershell-install:/opt/microsoft/powershell \
        `# These stores the PowerShell module for Azure.` \
        --volume powershell-modules-cache:/home/pi/.cache/powershell \
        --volume powershell-modules-config:/home/pi/.config/NuGet \
        --volume powershell-modules-share:/home/pi/.local/share/powershell \
        `# This stores the Azure authentication context.` \
        --volume powershell-azure-context:/home/pi/.Azure \
        `# Make the source code available and start the container in that directory.` \
        --volume "$PWD":/home/pi/retro-cloud-source \
        --workdir /home/pi/retro-cloud-source \
        "$tag" \
    )

    # We need the RPi configured controllers to connect and they need to be writable because EmulationStation always writes to them, but not risk breaking the RPi configs
    docker cp --follow-link /opt/retropie/configs/all/retroarch/. "${containerInstance}:/opt/retropie/configs/all/retroarch"
    # We need the configs but cannot copy the whole EmulationStation folder if this container is to mimic a user's RetroPie
    docker cp /opt/retropie/configs/all/emulationstation/es_input.cfg "${containerInstance}:/opt/retropie/configs/all/emulationstation/es_input.cfg"
    docker cp /opt/retropie/configs/all/emulationstation/es_temporaryinput.cfg "${containerInstance}:/opt/retropie/configs/all/emulationstation/es_temporaryinput.cfg"

else # Windows
    containerInstance=$(docker container create \
        --cap-add SYS_ADMIN \
        --device /dev/fuse \
        --env-file .env \
        --interactive \
        --rm \
        --tty \
        `# This stores the PowerShell installation, symlink is created later.` \
        --volume powershell-install:/opt/microsoft/powershell \
        `# These stores the PowerShell module for Azure.` \
        --volume powershell-modules-cache:/home/pi/.cache/powershell \
        --volume powershell-modules-config:/home/pi/.config/NuGet \
        --volume powershell-modules-share:/home/pi/.local/share/powershell \
        `# This stores the Azure authentication context.` \
        --volume powershell-azure-context:/home/pi/.Azure \
        `# Make the source code available and start the container in that directory.` \
        --volume "$PWD":/home/pi/retro-cloud-source \
        --workdir /home/pi/retro-cloud-source \
        "$tag" \
    )
fi

# We want writable .ssh/known_hosts but not risk that our own .ssh/ directory gets broken
docker cp "$HOME/.ssh" "${containerInstance}:/home/pi/.ssh"

# Start the prepared container
docker container start "$containerInstance"

# Symlink the PowerShell binary as 'pwsh', like install-ps.sh does
docker exec -d "$containerInstance" sudo ln --symbolic "/opt/microsoft/powershell/7/pwsh" "/usr/bin/pwsh"

# Attach and do interactive work in the container
docker container attach "$containerInstance"
