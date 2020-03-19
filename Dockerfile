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

# skel files are used as the basis for new users and include .bashrc etc:
# https://www.raspberrypi.org/documentation/linux/usage/users.md
# These files were copied from a RetroPie 4.5.1 on a RaspberryPi 3 and
# are included to make the image more realistic. One difference from
# base docker image is that .bashrc has colors enabled.
COPY docker/rpi/etc/skel /etc/skel

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
RUN git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git

# Enter the folder with the setup script
WORKDIR /home/pi/RetroPie-Setup

# Install RetroPie
# WARNING! This takes hours. Changing anything above this point in the Dockerfile will invalidate the cache of this layer, forcing an install.
RUN sudo ./retropie_packages.sh setup basic_install

# Exit the folder with the setup script
WORKDIR /home/pi

# Mimic RetroPie: Create fake file structure. Likely only available after a reboot and first run of EmulationStation.
RUN touch /opt/retropie/configs/all/autostart.sh \
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

# NOTE: Build and run this Dockerfile below
# NOTE: run as privileged, otherwise sshfs fails with "fuse: device not found, try 'modprobe fuse' first"
# docker build -t retro-cloud . ; docker run --privileged -it --rm retro-cloud

# NOTE: Publish
# docker push seriema/retro-cloud
