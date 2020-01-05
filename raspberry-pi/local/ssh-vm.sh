#!/bin/bash -i

# Abort on error
set -e
# Error if variable is unset
set -u

ssh $RETROCLOUD_VM_USER@$RETROCLOUD_VM_IP
