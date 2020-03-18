#!/bin/bash
# List installed packages. Used to compare installations to make a more complete Docker image for RetroPie.

# Abort on error, and error if variable is unset
set -eu

apt list --installed | sed 's:/[^/]*$::'

#diff -u rpi-debian.list rpi.list | grep '^\+' | sed -E 's/^\+//' > rpi-missing.list
