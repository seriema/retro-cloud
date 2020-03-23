#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

case "$(uname -m)" in
    # Assume Windows running Linux containers
    x86_64) tag="seriema/retro-cloud:amd64" ;;
    # Assume a Raspberry Pi 3
    armv7l) tag="seriema/retro-cloud:arm32v7" ;;
    # Fail
    *) echo "Unknown architecture: $(uname -m)" &% exit 1 ;;
esac

docker pull "$tag"
docker run --cap-add SYS_ADMIN --device /dev/fuse -it --rm "$tag"
