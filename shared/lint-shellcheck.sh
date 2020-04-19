#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

# Runs shellcheck as a docker app so you don't need it installed.
find . -type f -name '*.sh' -print0 | xargs -0 docker run --rm --volume "$PWD:/mnt" --workdir //mnt koalaman/shellcheck:stable --external-sources
