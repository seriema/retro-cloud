#!/bin/bash

# Abort on error
set -e
# Error if variable is unset
set -u

# There's a "permission denied" response when sending "./run-skyscraper.sh"
ssh $RETROCLOUD_VM_USER@$RETROCLOUD_VM_IP "./run-skyscraper.sh"
# ssh $RETROCLOUD_VM_USER@$RETROCLOUD_VM_IP "bash -i run-skyscraper.sh"
