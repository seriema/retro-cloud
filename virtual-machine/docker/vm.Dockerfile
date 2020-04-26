FROM ubuntu:18.04

# Install Prerequisites (over 500mb, so it takes a while)
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    # Pre-requisites for Skyscraper
    # Note: This is over 500mb!
    build-essential qt5-default \
    # Needed to download Skyscraper
    wget sudo

# Install Skyscraper (takes a while)
RUN mkdir -p "$HOME/skysource" \
    && cd "$HOME/skysource" \
    && wget -O - https://raw.githubusercontent.com/muldjord/skyscraper/master/update_skyscraper.sh | bash
