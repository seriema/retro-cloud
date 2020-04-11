#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

. ./helpers.sh
tag="seriema/retro-cloud:$(getArch)"

if [[ $(getArch) == "arm32v7" ]]; then # Raspberry Pi
    containerInstance=$(docker container create \
        --env PULSE_SERVER=unix:/run/user/1000/pulse/native \
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
        --volume /home/pi/.ssh:/home/pi/.ssh:ro \
        --volume /opt/retropie/configs/all/retroarch:/home/pi/.config/retroarch:ro \
        --volume /opt/retropie/configs/all/retroarch-joypads:/opt/retropie/configs/all/retroarch-joypads:ro \
        --volume /opt/vc:/opt/vc \
        --volume /run/user/1000:/run/user/1000 \
        --volume /var/run/dbus/:/var/run/dbus/ \
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
        --interactive \
        --rm \
        --tty \
        "$tag" \
    )
fi

# Do not copy the host's SSH keys, if this container is to mimic a user's RetroPie

# Run the prepared container
docker container start --attach --interactive "$containerInstance"
