#!/bin/bash
# Script takes optional parameter for branch name or commit hash.
branch=${1:-master}

# Abort on error, and error if variable is unset
set -eu

bash -i ssh-vm.sh "curl -OL https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/setup.sh"
bash -i ssh-vm.sh "bash -i setup.sh $branch"
bash -i ssh-vm.sh "rm setup.sh"
