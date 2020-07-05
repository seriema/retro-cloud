#!/bin/bash -i
# Script takes optional parameter for a command to send to the VM.
vmCmd=${1:-""}

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

# Lint disable: We do want the command to expand on the client side.
# shellcheck disable=SC2029
ssh "${RETROCLOUD_VM_USER}@${RETROCLOUD_VM_IP}" "$vmCmd"
