#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

echo 'Remove the shared directory and symlinks'
rm -r "$RETROCLOUD_VM_SHARE"
