#!/bin/bash

# Abort on error
set -e
# Error if variable is unset
set -u

echo 'Remove the shared directory and symlinks'
rm -r $RETROCLOUD_VM_SHARE
