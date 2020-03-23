#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

echo 'TEST: directory listing'
./docker/compose/directory-listing.sh

echo 'TEST: packages'
./docker/compose/packages.sh

echo 'TEST: user access'
./docker/compose/user-access.sh

echo 'TEST: Done.'
