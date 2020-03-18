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

# Mimic RaspberryPi: Create a user called "pi" and default password "raspberry" that's in the groups pi and sudo
RUN useradd --create-home pi --groups sudo --gid root \
    # && echo 'pi:raspberry' | chpasswd \
    && echo "pi ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/pi \
    && mkdir -p /home/pi \
    && chmod -R g+w /home/pi \
    && sudo chmod g+w -R /home/pi \
    && groupadd pi \
    && usermod -aG pi pi

# Change to the "pi" user
USER pi

#
# CREATE A RetroPie IMAGE
#
FROM raspberrypi AS retropie
WORKDIR /home/pi

## Install RetroPie ##

# Install the needed packages for the RetroPie setup script:
RUN sudo apt-get update \
    && sudo apt-get upgrade -y \
    && sudo apt-get install git lsb-release -y

# Download the latest RetroPie setup script:
RUN git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git \
    && sudo chown pi:pi -R RetroPie-Setup \
    && sudo chmod g+w -R RetroPie-Setup

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
    wget \
    # Required by create-vm.ps1 (ssh-keygen, ssh-keyscan)
    openssh-client

## Cleanup ##

# https://wiki.debian.org/ReduceDebian
RUN sudo rm -rf /usr/share/man/?? \
    && sudo apt autoremove

# https://docs.docker.com/develop/develop-images/dockerfile_best-practices
RUN sudo rm -rf /var/lib/apt/lists/*

# NOTE: Build and run this Dockerfile below
# NOTE: run as privileged, otherwise sshfs fails with "fuse: device not found, try 'modprobe fuse' first"
# docker build -t retro-cloud . ; docker run --privileged -it --rm retro-cloud

# NOTE: Publish
# docker push seriema/retro-cloud
