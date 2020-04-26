#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

. ./helpers.sh
tag="seriema/retro-cloud:vm"

docker run --rm -it "$tag"
