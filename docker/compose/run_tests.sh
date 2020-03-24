#!/bin/bash

# Abort on error, error if variable is unset, and enable debug output
set -eux

echo 'TEST: directory listing'
./docker/compose/directory-listing.sh

echo 'TEST: packages'
./docker/compose/packages.sh

echo 'TEST: user access'
./docker/compose/user-access.sh

echo 'TEST: Done.'
