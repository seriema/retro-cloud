FROM ubuntu:18.04

# Install prerequisites
RUN apt-get update \
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

# Mimic RetroPie: Create a user called "pi" and default password "raspberry"
RUN useradd --create-home pi --groups sudo --gid root
RUN echo 'pi:raspberry' | chpasswd
USER pi

# Copy source code to image
WORKDIR /home/pi
COPY ./raspberry-pi ./retro-cloud-setup
# Make sure we have write access (send sudo password: https://stackoverflow.com/a/39553081)
RUN echo "raspberry" | sudo -S chmod 775 retro-cloud-setup/
# Uncommented CMD because the interactive session is shut down if setup.sh fails.
# CMD cd retro-cloud-setup/ && bash setup.sh

# Mimic RetroPie: create fake files for the scripts to use
RUN sudo mkdir -p /opt/retropie/configs/all \
    && sudo touch /opt/retropie/configs/all/autostart.sh \
    && mkdir -p /home/pi/.emulationstation/gamelists \
    && mkdir -p /home/pi/.emulationstation/downloaded_media \
    && mkdir -p /home/pi/RetroPie/roms

# NOTE: Build and run this Dockerfile below
# NOTE: run as privileged, otherwise sshfs fails with "fuse: device not found, try 'modprobe fuse' first"
# docker build -t retro-cloud-test . ; docker run --privileged -it --rm --name retro-cloud retro-cloud-test
