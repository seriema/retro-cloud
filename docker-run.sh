#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

. ./helpers.sh
tag="seriema/retro-cloud:$(getArch)"

docker pull "$tag"
docker run --cap-add SYS_ADMIN --device /dev/fuse -it --rm "$tag"
