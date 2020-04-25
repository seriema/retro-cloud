#!/bin/bash
# Script takes optional parameter for branch name or commit hash.
branch=${1:-master}

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

bash -i ssh-vm.sh "curl -fOL https://raw.githubusercontent.com/seriema/retro-cloud/$branch/virtual-machine/setup.sh"
bash -i ssh-vm.sh "bash -i setup.sh $branch"
bash -i ssh-vm.sh "rm setup.sh"
