#!/bin/bash
# Script takes optional parameter for branch name or commit hash.
branch=${1:-develop}

# Abort on error, and error if variable is unset
set -eu

ssh $RETROCLOUD_VM_USER@$RETROCLOUD_VM_IP "wget -q https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/setup.sh"
ssh $RETROCLOUD_VM_USER@$RETROCLOUD_VM_IP "bash -i setup.sh $branch"
ssh $RETROCLOUD_VM_USER@$RETROCLOUD_VM_IP "rm setup.sh"
