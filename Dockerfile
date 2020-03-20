#
# CREATE A Fake Raspbian IMAGE
#
FROM ubuntu:18.04 AS raspberrypi

# Install prerequisites
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    # Required to run image as non-root user
    sudo

# Get rid of the warning: "debconf: unable to initialize frontend: Dialog"
# https://github.com/moby/moby/issues/27988
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Get rid of the warning: "debconf: delaying package configuration, since apt-utils is not installed"
RUN apt-get install -y apt-utils

# Add the raspberrypi.org and raspbian.org sources for packages expected by RetroPie-Setup when running on a RaspberryPi.
# Causes warnings on x86_64 (amd64) so it has to be conditional. Example: "N: Skipping acquire of configured file [...] as repository 'http://raspbian.raspberrypi.org/raspbian stretch InRelease' doesn't support architecture 'amd64'"
RUN if [ "$(uname -m)" = 'armv7l' ]; then \
        #
        # 1. Get the packages needed to add sources
        apt-get update && apt-get install -y \
        # curl is used to download the public keys in the next step (and used by the retro-cloud scripts)
        curl \
        # gnupg is used by apt-key in the next step
        gnupg \
        #
        # 2. Add the sources and their public keys
        # https://raspberrypi.stackexchange.com/questions/78427/what-repository-to-add-for-apt-to-find-raspberrypi-kernel
        && echo "deb http://raspbian.raspberrypi.org/raspbian/ stretch main contrib non-free rpi" >> /etc/apt/sources.list \
        && echo "deb http://archive.raspberrypi.org/debian/ stretch main ui" >> /etc/apt/sources.list.d/raspi.list \
        && curl -L http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | apt-key add - \
        # https://www.raspbian.org/RaspbianRepository
        && curl -L http://archive.raspbian.org/raspbian.public.key | apt-key add - \
        #
        # 3. Refresh the source list to make sure it worked
        && apt-get update; \
    fi

# Mimic RaspberryPi: Create a user called "pi" without a password that's in the groups pi and sudo
# Use `adduser` instead of `useradd`:
# * https://github.com/RetroPie/RetroPie-Setup/issues/2165#issuecomment-337932294
# * https://www.raspberrypi.org/documentation/linux/usage/users.md
RUN adduser --disabled-password --gecos '' pi \
    && adduser pi sudo \
    && echo 'pi ALL=(ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/010_pi-nopasswd

# Change to the "pi" user
USER pi

#
# CREATE A RetroPie IMAGE
#
FROM raspberrypi AS retropie
WORKDIR /home/pi

## Install RetroPie ##

# Install the needed packages for the RetroPie setup script on Debian/Ubuntu:
# https://retropie.org.uk/docs/Debian/
RUN sudo apt-get update \
    && sudo apt-get install -y \
    git dialog unzip xmlstarlet

# Download the latest RetroPie setup script:
RUN git clone https://github.com/RetroPie/RetroPie-Setup.git

# Enter the folder with the setup script
WORKDIR /home/pi/RetroPie-Setup

# Checkout the last working version (4.5.16)
RUN git checkout 3b6947c0

# Install RetroPie
# WARNING! This takes hours. Changing anything above this point in the Dockerfile will invalidate the cache of this layer, forcing an install.
RUN if [ "$(uname -m)" = 'armv7l' ]; then sudo __platform="rpi3" ./retropie_packages.sh setup basic_install; fi
RUN if [ "$(uname -m)" = 'x86_64' ]; then sudo ./retropie_packages.sh setup basic_install; fi
# The lines above can be commented out to speed up builds for testing, but then needs the line below.
# RUN sudo mkdir -p /opt/retropie/configs/all && sudo chmod g+w -R /opt/retropie/configs/all

# Exit the folder with the setup script
WORKDIR /home/pi

# Mimic RetroPie: Create fake file structure.
    # autostart.sh is available after a reboot.
RUN touch /opt/retropie/configs/all/autostart.sh \
    # downloaded_media is available after a first run of EmulationStation.
    && mkdir -p /home/pi/.emulationstation/downloaded_media \
    && sudo chmod g+w /home/pi/.emulationstation/downloaded_media

#
# CREATE A development IMAGE
#
FROM retropie


# Install packages found on a real RaspberryPi with RetroPie
RUN sudo apt-get update \
    && sudo apt-get install -y \
    # Required by most scripts
    curl

## Cleanup ##

# https://wiki.debian.org/ReduceDebian
RUN sudo rm -rf /usr/share/man/?? \
    && sudo apt autoremove -y

# https://docs.docker.com/develop/develop-images/dockerfile_best-practices
RUN sudo rm -rf /var/lib/apt/lists/*

## Docker specific workarounds ##

# HACK: give user root access to mount drives in Docker, otherwise sshfs fails with "fuse: failed to open /dev/fuse: Permission denied"
# NOTE: "pi" on a real RetroPie does not belong to root.
USER root
RUN adduser pi root
USER pi

# NOTE: run as privileged, otherwise sshfs fails with "fuse: device not found, try 'modprobe fuse' first"
# $ docker run --privileged -it --rm retro-cloud
