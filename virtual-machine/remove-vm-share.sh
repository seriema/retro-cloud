#!/bin/bash

# Abort on error
set -e
# Error if variable is unset
set -u

echo 'Remove the shared directory and symlinks'
sharePath="$HOME/retro-cloud-share"
rm -r $sharePath
