#!/bin/bash -i
# Script takes optional parameter for a command to send to the VM.
vmCmd=${1:-""}

# Abort on error
set -e
# Error if variable is unset
set -u

# Lint disable: We do want the command to expand on the client side.
# shellcheck disable=SC2029
ssh "${RETROCLOUD_VM_USER}@${RETROCLOUD_VM_IP}" "$vmCmd"
