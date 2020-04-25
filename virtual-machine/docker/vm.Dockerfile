FROM alpine:latest AS build

# Install Prerequisites (over 500mb, so it takes a while)
RUN apk add \
    --no-cache \
    --update \
    --update-cache \
    # Pre-requisites for Skyscraper
    # Note: This is over 500mb!
    # Note: alpine is not supported so we have to install some different packages
    # alpine equivalent of "build-essential"
    build-base \
    # alpine equiavalent of "qt5-default"
    qt5-qtbase qt5-qtbase-dev qtchooser \
    # Needed to download Skyscraper
    bash wget sudo

# Install Skyscraper (takes a while)
RUN mkdir -p "$HOME/skysource" \
    && cd "$HOME/skysource" \
    && wget -O - https://raw.githubusercontent.com/muldjord/skyscraper/master/update_skyscraper.sh | bash
