#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

# Accepts a tag (preferably the branch name) as an optional parameter for a command to send to the VM.
. ./helpers.sh
branch=${1:-"$(getBranch)"}
tag="rc:$branch"

if [[ $(getArch) == "arm32v7" ]]; then
    docker run \
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
        --volume /home/pi/.ssh:/home/pi/.ssh:ro \
        --volume /opt/retropie/configs/all/retroarch:/home/pi/.config/retroarch:ro \
        --volume /opt/retropie/configs/all/retroarch-joypads:/opt/retropie/configs/all/retroarch-joypads:ro \
        --volume /opt/vc:/opt/vc \
        --volume /run/user/1000:/run/user/1000 \
        --volume /var/run/dbus/:/var/run/dbus/ \
        "$tag"
else
    docker run \
        --cap-add SYS_ADMIN \
        --device /dev/fuse \
        --env-file .env \
        --interactive \
        --rm \
        --tty \
        --volume "$PWD":/home/pi/retro-cloud-source \
        --workdir /home/pi/retro-cloud-source \
        "$tag"
fi
