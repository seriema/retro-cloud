FROM alpine:latest AS runtime

RUN apk --no-cache upgrade \
    && apk add \
    --no-cache \
    --update \
    --update-cache \
    # libQt5Gui.so.5: qt5-qtbase-x11 (includes qt5-qtbase, libstdc++6, and gcc6), 87mb
    # libQt5Network.so.5: qt5-qtbase
    # libQt5Xml.so.5: qt5-qtbase
    # libQt5Core.so.5: qt5-qtbase
    # libstdc++.so.6: libstdc++6
    # libgcc_s.so.1: gcc6
    qt5-qtbase-x11


FROM runtime AS build

RUN apk add \
    --no-cache \
    --update \
    --update-cache \
    # Pre-requisites for Skyscraper
    # Note: This is over 500mb!
    # Note: alpine is not supported so we have to install some different packages
    # alpine equivalent of "build-essential" (177mb)
    build-base \
    # alpine equiavalent of "qt5-default" (350mb)
    qt5-qtbase qt5-qtbase-dev qtchooser \
    # Needed to download Skyscraper
    bash wget sudo

# Install Skyscraper (takes a while)
RUN mkdir -p "$HOME/skysource" \
    && cd "$HOME/skysource" \
    && wget -O - https://raw.githubusercontent.com/muldjord/skyscraper/master/update_skyscraper.sh | bash


FROM runtime

COPY --from=build /usr/local/etc/skyscraper /usr/local/etc/skyscraper/
COPY --from=build /usr/local/bin/Skyscraper /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/Skyscraper"]
