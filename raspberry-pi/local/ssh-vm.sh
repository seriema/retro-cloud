#!/bin/bash -i
# Script takes optional parameter for a command to send to the VM.
vmCmd=${1:-""}

# Abort on error
set -e
# Error if variable is unset
set -u

ssh $RETROCLOUD_VM_USER@$RETROCLOUD_VM_IP $vmCmd
