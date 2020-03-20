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

#
# Create a fat cache layer with most packages found per platform.
# Greatly reduces build time spent on the RetroPie-Setup layer (from >20min to <5min).
# WARNING! Rebuilding this cache layer takes a very long time! Don't modify it often.
RUN if [ "$(uname -m)" = 'armv7l' ]; then \
        apt-get update && apt-get install -y \
        adduser apt autoconf automake autopoint autotools-dev base-files base-passwd bash binutils binutils-arm-linux-gnueabihf binutils-common bsdmainutils bsdutils build-essential bzip2 ca-certificates cmake cmake-data coreutils cpp cpp-7 cron dash dbus debconf debhelper debianutils device-tree-compiler devscripts dh-autoreconf dh-strip-nondeterminism dialog diffutils dirmngr distro-info-data dpkg dpkg-dev e2fsprogs fbi fbset fcitx-bin fcitx-libs-dev fdisk file findutils fontconfig fontconfig-config fonts-dejavu-core fonts-freefont-ttf fuse g++ g++-7 gcc gcc-7 gcc-7-base gcc-8-base gettext gettext-base ghostscript gir1.2-fcitx-1.0 gir1.2-glib-2.0 gir1.2-ibus-1.0 git git-man gnupg gnupg-l10n gnupg-utils gpg gpg-agent gpg-wks-client gpg-wks-server gpgconf gpgsm gpgv grep groff-base gzip hostname init-system-helpers intltool-debian iso-codes krb5-locales less liba52-0.7.4 libaa1 libacl1 libapparmor1 libapt-inst2.0 libapt-pkg5.0 libarchive-zip-perl libarchive13 libasan4 libasn1-8-heimdal libasound2 libasound2-data libasound2-dev libass5 libass9 libassuan0 libasyncns0 libatomic1 libattr1 libaudio2 libaudit-common libaudit1 libavahi-client3 libavahi-common-data libavahi-common3 libavc1394-0 libavcodec-dev libavcodec57 libavdevice-dev libavdevice57 libavfilter-dev libavfilter6 libavformat-dev libavformat57 libavresample-dev libavresample3 libavutil-dev libavutil55 libbasicusageenvironment1 libbinutils libblkid1 libbluray2 libbs2b0 libbsd0 libbz2-1.0 libc-bin libc-dev-bin libc6 libc6-dev libcaca0 libcairo2 libcap-ng0 libcc1-0 libcddb2 libcdio-cdda2 libcdio-paranoia2 libcdio17 libchromaprint1 libcilkrts5 libcom-err2 libcroco3 libcups2 libcupsimage2 libcurl3-gnutls libcurl4 libcurl4-openssl-dev libdatrie1 libdb5.3 libdbus-1-3 libdbus-1-dev libdc1394-22 libdca0 libdebconfclient0 libdouble-conversion1 libdpkg-perl libdrm-amdgpu1 libdrm-common libdrm-dev libdrm-etnaviv1 libdrm-exynos1 libdrm-freedreno1 libdrm-nouveau2 libdrm-omap1 libdrm-radeon1 libdrm-tegra0 libdrm2 libdvbpsi10 libdvdnav4 libdvdread4 libebml4v5 libedit2 libegl-mesa0 libegl1 libegl1-mesa libegl1-mesa-dev libelf1 liberror-perl libevdev2 libexif12 libexpat1 libext2fs2 libfaad2 libfcitx-config4 libfcitx-core0 libfcitx-gclient1 libfcitx-qt0 libfcitx-utils0 libfdisk1 libffi6 libfftw3-double3 libfile-homedir-perl libfile-stripnondeterminism-perl libfile-which-perl libflac8 libflite1 libfontconfig1 libfreeimage-dev libfreeimage3 libfreetype6 libfreetype6-dev libfribidi0 libfuse2 libgbm-dev libgbm1 libgcc-7-dev libgcc1 libgcrypt20 libgdbm-compat4 libgdbm5 libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgettextpo0 libgif7 libgirepository-1.0-1 libgl1 libgl1-mesa-dev libgl1-mesa-dri libglapi-mesa libgles1 libgles2 libgles2-mesa-dev libglib2.0-0 libglib2.0-bin libglib2.0-data libglib2.0-dev libglib2.0-dev-bin libglu1-mesa libglu1-mesa-dev libglvnd-core-dev libglvnd-dev libglvnd0 libglx-mesa0 libglx0 libgme0 libgmp10 libgnutls30 libgomp1 libgpg-error0 libgpm2 libgraphite2-3 libgroupsock8 libgs9 libgs9-common libgsm1 libgssapi-krb5-2 libgssapi3-heimdal libgudev-1.0-0 libharfbuzz0b libhcrypto4-heimdal libheimbase1-heimdal libheimntlm0-heimdal libhogweed4 libhx509-5-heimdal libibus-1.0-5 libibus-1.0-dev libice-dev libice6 libicu60 libidn11 libidn2-0 libiec61883-0 libijs-0.35 libilmbase12 libinput-bin libinput10 libisl19 libjack-jackd2-0 libjbig0 libjbig2dec0 libjpeg62-turbo libjpeg8 libjsoncpp1 libjxr0 libk5crypto3 libkate1 libkeyutils1 libkmod2 libkrb5-26-heimdal libkrb5-3 libkrb5support0 libksba8 liblcms2-2 libldap-2.4-2 libldap-common liblirc-client0 liblivemedia57 libllvm9 liblua5.2-0 liblz4-1 liblzma5 liblzo2-2 libmad0 libmagic-mgc libmagic1 libmatroska6v5 libmicrodns0 libmng1 libmount1 libmp3lame0 libmpc3 libmpcdec6 libmpdec2 libmpeg2-4 libmpfr6 libmpg123-0 libmtdev1 libmtp-common libmtp9 libmysofa0 libncurses5 libncursesw5 libnettle6 libnfs8 libnghttp2-14 libnorm1 libnpth0 libogg0 libopenal-data libopenal1 libopenexr22 libopengl0 libopenjp2-7 libopenmpt-modplug1 libopenmpt0 libopus0 libp11-kit0 libpam-modules libpam-modules-bin libpam-runtime libpam0g libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpaper1 libpciaccess-dev libpciaccess0 libpcre16-3 libpcre3 libpcre3-dev libpcre32-3 libpcrecpp0v5 libperl5.26 libpgm-5.2-0 libpipeline1 libpixman-1-0 libpng-dev libpng12-0 libpng16-16 libpostproc-dev libpostproc54 libprocps6 libprotobuf-lite10 libpsl5 libpthread-stubs0-dev libpulse0 libpython-stdlib libpython2.7-minimal libpython2.7-stdlib libpython3-stdlib libpython3.6-minimal libpython3.6-stdlib libqt4-dbus libqt4-xml libqt5core5a libqt5dbus5 libqt5gui5 libqt5network5 libqt5svg5 libqt5widgets5 libqt5x11extras5 libqtcore4 libqtdbus4 libqtgui4 libraspberrypi-bin libraspberrypi-dev libraspberrypi0 libraw1394-11 libraw15 libreadline7 libresid-builder0c2a librhash0 libroken18-heimdal librsvg2-2 librtmp1 librubberband2 libsamplerate0 libsamplerate0-dev libsasl2-2 libsasl2-modules libsasl2-modules-db libsdl-image1.2 libsdl1.2debian libsdl2-2.0-0 libsdl2-dev libseccomp2 libsecret-1-0 libsecret-common libselinux1 libsemanage-common libsemanage1 libsensors4 libsepol1 libshine3 libshout3 libsidplay2 libsigsegv2 libslang2 libsm-dev libsm6 libsmartcols1 libsnappy1v5 libsndfile1 libsndio-dev libsndio6.1 libsodium23 libsoxr0 libspeex-dev libspeex1 libspeexdsp-dev libspeexdsp1 libsqlite3-0 libss2 libssh-gcrypt-4 libssh2-1 libssl1.0.0 libssl1.1 libstdc++-7-dev libstdc++6 libswresample-dev libswresample2 libswscale-dev libswscale4 libsystemd0 libtag1v5 libtag1v5-vanilla libtasn1-6 libthai-data libthai0 libtheora0 libtiff5 libtimedate-perl libtinfo5 libtool libtwolame0 libubsan0 libudev-dev libudev1 libunistring2 libupnp6 libusageenvironment3 libusb-1.0-0 libusb-1.0-0-dev libuuid1 libuv1 libva-drm1 libva-drm2 libva-wayland1 libva-x11-1 libva-x11-2 libva1 libva2 libvdpau1 libvlc-bin libvlc-dev libvlc5 libvlccore-dev libvlccore9 libvorbis0a libvorbisenc2 libvorbisfile3 libvpx5 libwacom-common libwacom2 libwavpack1 libwayland-bin libwayland-client0 libwayland-cursor0 libwayland-dev libwayland-egl1 libwayland-server0 libwebp6 libwebpmux2 libwebpmux3 libwind0-heimdal libwrap0 libx11-6 libx11-data libx11-dev libx11-xcb-dev libx11-xcb1 libx264-148 libx264-152 libx265-146 libx265-95 libxau-dev libxau6 libxcb-dri2-0 libxcb-dri2-0-dev libxcb-dri3-0 libxcb-dri3-dev libxcb-glx0 libxcb-glx0-dev libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-present-dev libxcb-present0 libxcb-randr0 libxcb-randr0-dev libxcb-render-util0 libxcb-render0 libxcb-render0-dev libxcb-shape0 libxcb-shape0-dev libxcb-shm0 libxcb-sync-dev libxcb-sync1 libxcb-util1 libxcb-xfixes0 libxcb-xfixes0-dev libxcb-xinerama0 libxcb-xkb1 libxcb-xv0 libxcb1 libxcb1-dev libxcursor-dev libxcursor1 libxdamage-dev libxdamage1 libxdmcp-dev libxdmcp6 libxext-dev libxext6 libxfixes-dev libxfixes3 libxi-dev libxi6 libxinerama-dev libxinerama1 libxkbcommon-dev libxkbcommon-x11-0 libxkbcommon0 libxml2 libxmuu1 libxrandr-dev libxrandr2 libxrender-dev libxrender1 libxshmfence-dev libxshmfence1 libxslt1.1 libxss-dev libxss1 libxt-dev libxt6 libxv-dev libxv1 libxvidcore4 libxxf86vm-dev libxxf86vm1 libzmq5 libzstd1 libzvbi-common libzvbi0 linux-libc-dev login lsb-base lsb-release m4 make man-db mawk mc mc-data mesa-common-dev meson mime-support mount multiarch-support nano ncurses-base ncurses-bin netbase ninja-build omxplayer openssh-client openssl passwd patch perl perl-base perl-modules-5.26 pinentry-curses pkg-config po-debconf poppler-data powermgmt-base procps publicsuffix python python-apt-common python-minimal python-pyudev python-six python2.7 python2.7-minimal python3 python3-apt python3-dbus python3-distutils python3-gi python3-lib2to3 python3-minimal python3-software-properties python3.6 python3.6-minimal qdbus qtchooser qtcore4-l10n rapidjson-dev raspberrypi-bootloader readline-common sed sensible-utils shared-mime-info software-properties-common sshfs sudo sysvinit-utils tar ubuntu-keyring ucf udev unattended-upgrades unzip util-linux vlc vlc-bin vlc-data vlc-l10n vlc-plugin-base vlc-plugin-qt vlc-plugin-video-output wget x11-common x11proto-core-dev x11proto-damage-dev x11proto-dev x11proto-fixes-dev x11proto-input-dev x11proto-randr-dev x11proto-scrnsaver-dev x11proto-xext-dev x11proto-xf86vidmode-dev x11proto-xinerama-dev xauth xdg-user-dirs xkb-data xmlstarlet xorg-sgml-doctools xtrans-dev xz-utils zlib1g zlib1g-dev \
        ; \
    fi
RUN if [ "$(uname -m)" = 'x86_64' ]; then \
        apt-get update && apt-get install -y \
        adduser adwaita-icon-theme apt base-files base-passwd bash binutils binutils-common binutils-x86-64-linux-gnu bison bsdutils build-essential bzip2 ca-certificates cmake cmake-data coreutils cpp cpp-7 cron dash dbus dbus-user-session dconf-gsettings-backend dconf-service debconf debianutils dialog diffutils dirmngr distro-info-data dpkg dpkg-dev e2fsprogs fdisk feh file findutils flex fontconfig fontconfig-config fonts-dejavu-core fonts-freefont-ttf freeglut3 fuse g++ g++-7 gcc gcc-7 gcc-7-base gcc-8-base gir1.2-glib-2.0 gir1.2-ibus-1.0 git git-man glib-networking glib-networking-common glib-networking-services gnome-terminal gnome-terminal-data gnupg gnupg-l10n gnupg-utils gpg gpg-agent gpg-wks-client gpg-wks-server gpgconf gpgsm gpgv grep gsettings-desktop-schemas gtk-update-icon-cache gzip hicolor-icon-theme hostname humanity-icon-theme init-system-helpers iso-codes krb5-locales less liba52-0.7.4 libaa1 libacl1 libapparmor1 libapt-inst2.0 libapt-pkg5.0 libarchive13 libargon2-0 libaribb24-0 libasan4 libasn1-8-heimdal libasound2 libasound2-data libasound2-dev libass9 libassuan0 libasyncns0 libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatomic1 libatspi2.0-0 libattr1 libaudit-common libaudit1 libavahi-client3 libavahi-common-data libavahi-common3 libavc1394-0 libavcodec-dev libavcodec57 libavdevice-dev libavdevice57 libavfilter-dev libavfilter6 libavformat-dev libavformat57 libavresample-dev libavresample3 libavutil-dev libavutil55 libbasicusageenvironment1 libbinutils libbison-dev libblkid1 libbluray2 libboost-filesystem-dev libboost-filesystem1.65-dev libboost-filesystem1.65.1 libboost-system1.65-dev libboost-system1.65.1 libboost1.65-dev libbs2b0 libbsd0 libbz2-1.0 libc-bin libc-dev-bin libc6 libc6-dev libcaca0 libcairo-gobject2 libcairo2 libcap-ng0 libcap2 libcapnp-0.6.1 libcc1-0 libcddb2 libcdio-cdda2 libcdio-paranoia2 libcdio17 libcg libcggl libchromaprint1 libcilkrts5 libcolord2 libcom-err2 libcroco3 libcryptsetup12 libcrystalhd3 libcups2 libcurl3-gnutls libcurl4 libcurl4-openssl-dev libdatrie1 libdb5.3 libdbus-1-3 libdbus-1-dev libdc1394-22 libdca0 libdconf1 libdebconfclient0 libdevmapper1.02.1 libdouble-conversion1 libdpkg-perl libdrm-amdgpu1 libdrm-common libdrm-dev libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 libdrm2 libdvbpsi10 libdvdnav4 libdvdread4 libebml4v5 libedit2 libegl-mesa0 libegl1 libegl1-mesa-dev libelf1 libepoxy0 liberror-perl libevdev2 libexif12 libexpat1 libext2fs2 libfaad2 libfdisk1 libffi6 libfftw3-double3 libflac8 libflite1 libfontconfig1 libfreeimage-dev libfreeimage3 libfreetype6 libfreetype6-dev libfribidi0 libfuse2 libgbm-dev libgbm1 libgcc-7-dev libgcc1 libgcrypt20 libgdbm-compat4 libgdbm5 libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgif7 libgirepository-1.0-1 libgl1 libgl1-mesa-dev libgl1-mesa-dri libglapi-mesa libgles1 libgles2 libgles2-mesa-dev libglew-dev libglew2.0 libglib2.0-0 libglib2.0-bin libglib2.0-data libglib2.0-dev libglib2.0-dev-bin libglu1-mesa libglu1-mesa-dev libglvnd-core-dev libglvnd-dev libglvnd0 libglx-mesa0 libglx0 libgme0 libgmp10 libgnutls30 libgomp1 libgpg-error0 libgpm2 libgraphite2-3 libgroupsock8 libgsm1 libgssapi-krb5-2 libgssapi3-heimdal libgtk-3-0 libgtk-3-common libgudev-1.0-0 libharfbuzz0b libhcrypto4-heimdal libheimbase1-heimdal libheimntlm0-heimdal libhogweed4 libhx509-5-heimdal libibus-1.0-5 libibus-1.0-dev libice-dev libice6 libicu60 libid3tag0 libidn11 libidn2-0 libiec61883-0 libilmbase12 libimlib2 libinput-bin libinput10 libip4tc0 libisl19 libitm1 libjack-jackd2-0 libjbig0 libjpeg-turbo8 libjpeg8 libjson-c3 libjson-glib-1.0-0 libjson-glib-1.0-common libjsoncpp1 libjxr0 libk5crypto3 libkate1 libkeyutils1 libkmod2 libkrb5-26-heimdal libkrb5-3 libkrb5support0 libksba8 liblcms2-2 libldap-2.4-2 libldap-common liblirc-client0 liblivemedia62 libllvm9 liblsan0 liblua5.2-0 liblz4-1 liblzma5 liblzo2-2 libmad0 libmagic-mgc libmagic1 libmatroska6v5 libmicrodns0 libmirclient-dev libmirclient9 libmircommon-dev libmircommon7 libmircookie-dev libmircookie2 libmircore-dev libmircore1 libmirprotobuf3 libmount1 libmp3lame0 libmpc3 libmpcdec6 libmpdec2 libmpeg2-4 libmpfr6 libmpg123-0 libmpx2 libmtdev1 libmtp-common libmtp9 libmysofa0 libncurses5 libncursesw5 libnettle6 libnfs11 libnghttp2-14 libnorm1 libnpth0 libnuma1 libogg0 libopenal-data libopenal1 libopenexr22 libopengl0 libopenjp2-7 libopenmpt-modplug1 libopenmpt0 libopus0 libp11-kit0 libpam-modules libpam-modules-bin libpam-runtime libpam-systemd libpam0g libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpciaccess-dev libpciaccess0 libpcre16-3 libpcre3 libpcre3-dev libpcre32-3 libpcrecpp0v5 libperl5.26 libpgm-5.2-0 libpixman-1-0 libplacebo4 libpng-dev libpng16-16 libpostproc-dev libpostproc54 libprocps6 libprotobuf-dev libprotobuf-lite10 libprotobuf10 libproxy1v5 libpsl5 libpthread-stubs0-dev libpulse-dev libpulse-mainloop-glib0 libpulse0 libpython-stdlib libpython2.7-minimal libpython2.7-stdlib libpython3-stdlib libpython3.6-minimal libpython3.6-stdlib libqt5core5a libqt5dbus5 libqt5gui5 libqt5network5 libqt5svg5 libqt5widgets5 libqt5x11extras5 libquadmath0 libraw1394-11 libraw16 libreadline7 libresid-builder0c2a librest-0.7-0 librhash0 libroken18-heimdal librsvg2-2 librsvg2-common librtmp1 librubberband2 libsamplerate0 libsamplerate0-dev libsasl2-2 libsasl2-modules libsasl2-modules-db libsdl-image1.2 libsdl1.2debian libsdl2-2.0-0 libsdl2-dev libseccomp2 libsecret-1-0 libsecret-common libselinux1 libsemanage-common libsemanage1 libsensors4 libsepol1 libshine3 libshout3 libsidplay2 libsigsegv2 libslang2 libsm-dev libsm6 libsmartcols1 libsnappy1v5 libsndfile1 libsndio-dev libsndio6.1 libsodium23 libsoup-gnome2.4-1 libsoup2.4-1 libsoxr0 libspeex-dev libspeex1 libspeexdsp-dev libspeexdsp1 libsqlite3-0 libss2 libssh-gcrypt-4 libssh2-1 libssl1.0.0 libssl1.1 libstdc++-7-dev libstdc++6 libswresample-dev libswresample2 libswscale-dev libswscale4 libsystemd0 libtag1v5 libtag1v5-vanilla libtasn1-6 libthai-data libthai0 libtheora0 libtiff5 libtinfo5 libtsan0 libtwolame0 libubsan0 libudev-dev libudev1 libunistring2 libupnp6 libusageenvironment3 libusb-1.0-0 libusb-1.0-0-dev libuuid1 libuv1 libva-drm2 libva-wayland2 libva-x11-2 libva2 libvdpau1 libvlc-bin libvlc-dev libvlc5 libvlccore-dev libvlccore9 libvorbis0a libvorbisenc2 libvorbisfile3 libvpx5 libvte-2.91-0 libvte-2.91-common libvulkan-dev libvulkan1 libwacom-common libwacom2 libwavpack1 libwayland-bin libwayland-client0 libwayland-cursor0 libwayland-dev libwayland-egl1 libwayland-server0 libwebp6 libwebpmux3 libwind0-heimdal libwrap0 libx11-6 libx11-data libx11-dev libx11-xcb-dev libx11-xcb1 libx264-152 libx265-146 libxau-dev libxau6 libxcb-dri2-0 libxcb-dri2-0-dev libxcb-dri3-0 libxcb-dri3-dev libxcb-glx0 libxcb-glx0-dev libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-present-dev libxcb-present0 libxcb-randr0 libxcb-randr0-dev libxcb-render-util0 libxcb-render0 libxcb-render0-dev libxcb-shape0 libxcb-shape0-dev libxcb-shm0 libxcb-sync-dev libxcb-sync1 libxcb-util1 libxcb-xfixes0 libxcb-xfixes0-dev libxcb-xinerama0 libxcb-xkb1 libxcb-xv0 libxcb1 libxcb1-dev libxcomposite1 libxcursor-dev libxcursor1 libxdamage-dev libxdamage1 libxdmcp-dev libxdmcp6 libxext-dev libxext6 libxfixes-dev libxfixes3 libxi-dev libxi6 libxinerama-dev libxinerama1 libxkbcommon-dev libxkbcommon-x11-0 libxkbcommon0 libxml2 libxmuu1 libxrandr-dev libxrandr2 libxrender-dev libxrender1 libxshmfence-dev libxshmfence1 libxslt1.1 libxss-dev libxss1 libxt-dev libxt6 libxv-dev libxv1 libxvidcore4 libxxf86vm-dev libxxf86vm1 libzmq5 libzstd1 libzvbi-common libzvbi0 linux-libc-dev login lsb-base lsb-release m4 make mawk mc mc-data mesa-common-dev meson mime-support mount multiarch-support nasm ncurses-base ncurses-bin netbase ninja-build nvidia-cg-dev nvidia-cg-toolkit openssh-client openssl passwd patch perl perl-base perl-modules-5.26 pinentry-curses pkg-config powermgmt-base procps publicsuffix python python-apt-common python-minimal python-pyudev python-six python2.7 python2.7-minimal python3 python3-apt python3-dbus python3-distutils python3-gi python3-lib2to3 python3-minimal python3-software-properties python3.6 python3.6-minimal rapidjson-dev readline-common sed sensible-utils shared-mime-info software-properties-common sshfs sudo systemd systemd-sysv sysvinit-utils tar ubuntu-keyring ubuntu-mono ucf unattended-upgrades unzip util-linux vlc vlc-bin vlc-data vlc-plugin-base vlc-plugin-qt vlc-plugin-video-output wget x11-common x11proto-core-dev x11proto-damage-dev x11proto-dev x11proto-fixes-dev x11proto-input-dev x11proto-randr-dev x11proto-scrnsaver-dev x11proto-xext-dev x11proto-xf86vidmode-dev x11proto-xinerama-dev xauth xdg-user-dirs xkb-data xmlstarlet xorg-sgml-doctools xtrans-dev xz-utils yudit-common zlib1g zlib1g-dev \
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
