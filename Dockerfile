#
# CREATE A Fake Raspbian IMAGE
#
FROM debian:stretch AS raspberrypi

# Mentioned in https://hub.docker.com/_/debian and seen in https://github.com/laseryuan/docker-apps/blob/db3c154ebe/retropie/Dockerfile.templ#L13
ENV LANG C.UTF-8

# Install prerequisites
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    # Required to run image as non-root user
    sudo

# Get rid of the warning: "debconf: unable to initialize frontend: Dialog"
# https://serverfault.com/a/797318/565229
ARG DEBIAN_FRONTEND=noninteractive

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
        && curl -fL http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | apt-key add - \
        # https://www.raspbian.org/RaspbianRepository
        && curl -fL http://archive.raspbian.org/raspbian.public.key | apt-key add - \
        #
        # 3. Refresh the source list to make sure it worked
        && apt-get update; \
    fi

#
# Create a fat cache layer with most packages found per platform.
# Greatly reduces build time spent on the RetroPie-Setup layer (from >20min to <5min).
# WARNING! Rebuilding this cache layer takes a very long time! Don't modify it often.
RUN if [ "$(uname -m)" = 'armv7l' ]; then \
        apt-get update && apt-get install -y \
        autoconf automake autopoint autotools-dev binutils bison bsdmainutils build-essential bzip2 ca-certificates cmake cpp dbus debhelper device-tree-compiler devscripts dh-autoreconf dh-strip-nondeterminism dialog dirmngr distro-info-data dpkg-dev fbi fbset fcitx-bin fcitx-libs-dev file flex fontconfig fontconfig-config fonts-dejavu-core fonts-freefont-ttf g++ gcc gettext gettext-base ghostscript git gnupg gpg groff-base insserv intltool-debian krb5-locales less libasound2-dev libavcodec-dev libavdevice-dev libavformat-dev libcurl4-openssl-dev libdbus-1-dev libegl1-mesa-dev libfreeimage-dev libfreetype6-dev libgbm-dev libgl1-mesa-dev libgles2-mesa-dev libglu1-mesa-dev libibus-1.0-dev libjpeg-dev libraspberrypi-bin libraspberrypi-dev libraspberrypi-doc libsamplerate0-dev libsndio-dev libspeexdsp-dev libudev-dev libusb-1.0-0-dev libvlccore-dev libvlc-dev libxcursor-dev libxext-dev libxi-dev libxinerama-dev libxkbcommon-dev libxrandr-dev libxss-dev libxt-dev libxv-dev libxxf86vm-dev lsb-release m4 make mc mesa-common-dev meson mime-support netbase ninja-build omxplayer openssh-client openssl patch perl pinentry-curses pkg-config po-debconf poppler-data procps publicsuffix python python2.7 python3 python-pyudev qdbus qtchooser qtcore4-l10n rapidjson-dev raspberrypi-bootloader readline-common shared-mime-info systemd ucf udev unzip vlc wget x11-common xauth xkb-data xmlstarlet xorg-sgml-doctools xtrans-dev xz-utils zlib1g-dev \
        ; \
    fi
RUN if [ "$(uname -m)" = 'x86_64' ]; then \
        # Note: The N64 emulator mupen64plus is used on amd64 but requires a newer version of cmake (3.9+) than
        # is available (3.7.2) on debian:stretch, so it will be installed separately.
        apt-get update && apt-get install -y \
        adduser adwaita-icon-theme apt aspell aspell-en at-spi2-core base-files base-passwd bash binutils bison bsdmainutils bsdutils build-essential bzip2 ca-certificates coreutils cpp cron dash dbus dbus-user-session dconf-gsettings-backend dconf-service debconf debianutils desktop-file-utils dialog dictionaries-common diffutils dirmngr distro-info-data dmsetup dosfstools dpkg dpkg-dev e2fsprogs eject emacsen-common enchant fakeroot feh file findutils flex fontconfig fontconfig-config fonts-dejavu-core fonts-freefont-ttf freeglut3 fuse g++ gcc gdisk git glib-networking glib-networking-common glib-networking-services gnome-terminal gnome-terminal-data gnupg gpg grep groff-base gsettings-desktop-schemas gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-pulseaudio gstreamer1.0-x gtk-update-icon-cache gvfs gvfs-common gvfs-daemons gvfs-libs gzip hicolor-icon-theme hostname hunspell-en-us i965-va-driver init-system-helpers iso-codes krb5-locales less libasound2-dev libavcodec-dev libavdevice-dev libavformat-dev libboost-filesystem-dev libcurl4-openssl-dev libfreeimage-dev libfreetype6-dev libglew-dev libpulse-dev libsamplerate0-dev libsdl2-dev libspeexdsp-dev libudev-dev libusb-1.0-0-dev libvlccore-dev libvlc-dev libvulkan-dev libxkbcommon-dev m4 make man-db manpages manpages-dev mawk mc mc-data mesa-common-dev mesa-va-drivers mesa-vdpau-drivers meson mime-support mount multiarch-support nasm ncurses-base ncurses-bin netbase ninja-build notification-daemon ntfs-3g openssh-client openssl parted passwd patch perl pinentry-curses pkg-config policykit-1 powermgmt-base procps publicsuffix python python2.7 python3 python-apt-common python-minimal python-pyudev python-six python-talloc qt5-gtk-platformtheme qttranslations5-l10n rapidjson-dev readline-common samba-libs sed sensible-utils shared-mime-info software-properties-common sshfs sudo systemd systemd-sysv sysvinit-utils tar ucf udev udisks2 unattended-upgrades unzip util-linux va-driver-all vdpau-driver-all vlc vlc-bin vlc-data vlc-l10n vlc-plugin-base vlc-plugin-notify vlc-plugin-qt vlc-plugin-samba vlc-plugin-skins2 vlc-plugin-video-output vlc-plugin-video-splitter vlc-plugin-visualization wget x11-common xauth xdg-user-dirs xdg-utils xkb-data xmlstarlet xorg-sgml-doctools xtrans-dev xz-utils yelp yelp-xsl yudit-common zlib1g zlib1g-dev \
        ; \
        # Install cmake 3.9+ (which depends on libarchive13): https://backports.debian.org/
        echo "deb http://deb.debian.org/debian stretch-backports-sloppy main" | sudo tee -a /etc/apt/sources.list >/dev/null \
        && sudo apt-get update \
        && sudo apt-get -t stretch-backports-sloppy install -y libarchive13 \
        && echo "deb http://deb.debian.org/debian stretch-backports main" | sudo tee -a /etc/apt/sources.list >/dev/null \
        && sudo apt-get update \
        && sudo apt-get -t stretch-backports install -y cmake \
        ; \
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

# Install the needed packages for the RetroPie setup script on Raspbian and Debian/Ubuntu respectively.
# RPi: https://retropie.org.uk/docs/Manual-Installation/
RUN if [ "$(uname -m)" = 'armv7l' ]; then sudo apt-get update && sudo apt-get install -y git lsb-release; fi
# Linux: https://retropie.org.uk/docs/Debian/
RUN if [ "$(uname -m)" = 'x86_64' ]; then sudo apt-get update && sudo apt-get install -y git dialog unzip xmlstarlet; fi

# Download the latest RetroPie setup script:
RUN git clone https://github.com/RetroPie/RetroPie-Setup.git

# Enter the folder with the setup script
WORKDIR /home/pi/RetroPie-Setup

# Emergency use only: Checkout a specific version to avoid sudden upgrades that break the image
# It doesn't work after a few releases as it's not supported: https://retropie.org.uk/forum/topic/26754/installing-a-specific-version-of-retropie
# Example 1 commit: 4.5.17 + error code fix https://github.com/RetroPie/RetroPie-Setup/commit/50e8300
# RUN git checkout 50e8300
# Example 2 tag: 4.6.0 https://github.com/RetroPie/RetroPie-Setup/releases/tag/4.6
# RUN git checkout tags/4.6

# Install RetroPie
# WARNING! Rebuilding this cache layer takes a very long time! Don't modify it often.
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
