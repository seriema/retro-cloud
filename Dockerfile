#
# CREATE A Fake Raspbian IMAGE
#
FROM ubuntu:18.04 AS raspberrypi

# Install prerequisites
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    # Required by most scripts (when running on the rpi)
    sudo \
    # Required by install-ps-ubuntu.sh (add-apt-repository, wget)
    software-properties-common \
    wget \
    # Required by create-vm.ps1 (ssh-keygen, ssh-keyscan)
    openssh-client \
    # Installed by mount-vm-share.sh (preinstalling speeds up testing of the script)
    sshfs \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

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

# Enter the folder with the setup script:
WORKDIR /home/pi/RetroPie-Setup

# Install RetroPie
# WARNING! This takes hours. Changing anything above this point in the Dockerfile will invalidate the cache of this layer, forcing an install.
RUN sudo ./retropie_packages.sh setup basic_install

# Mimic RetroPie: Create fake file structure. Likely only available after a reboot and first run of EmulationStation.
RUN touch /opt/retropie/configs/all/autostart.sh \
    && mkdir -p /home/pi/.emulationstation/downloaded_media \
    && sudo chmod g+w /home/pi/.emulationstation/downloaded_media

#
# CREATE A development IMAGE
#
FROM retropie
# Copy source code to image
WORKDIR /home/pi
COPY ./raspberry-pi ./retro-cloud-setup
RUN sudo chown pi:pi -R retro-cloud-setup \
    && sudo chmod g+w -R retro-cloud-setup
# Commented CMD because the interactive session is shut down if setup.sh fails.
# CMD cd retro-cloud-setup/ && bash setup.sh


# NOTE: Build and run this Dockerfile below
# NOTE: run as privileged, otherwise sshfs fails with "fuse: device not found, try 'modprobe fuse' first"
# docker build -t retro-cloud . ; docker run --privileged -it --rm retro-cloud

# NOTE: Publish
# docker push seriema/retro-cloud