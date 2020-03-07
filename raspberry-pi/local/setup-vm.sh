#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

ssh $RETROCLOUD_VM_USER@$RETROCLOUD_VM_IP "wget -O - https://raw.githubusercontent.com/seriema/retro-cloud/develop/virtual-machine/setup.sh | bash -i"
