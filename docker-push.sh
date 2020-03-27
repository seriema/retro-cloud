#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

. ./helpers.sh
tag="seriema/retro-cloud:$(getArch)"

docker push "$tag"
