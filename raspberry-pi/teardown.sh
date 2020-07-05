#!/bin/bash
# Take a parameter for prefixing the Azure resource group name. This is useful when you want to
# destroy a resource group that was created outside of the scripts during development, or in CI
# when the resource group prefix is predictable and the teardown can happen in a context (such as a
# separate container) without '.retro-cloud.env' available.
rgPrefix=${1:-''}

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

# Disable lint: the .retro-cloud.env file is created by create-vm.ps1 so it can't be included for shellcheck (https://github.com/koalaman/shellcheck/wiki/SC1091)
# shellcheck disable=SC1090
source "$HOME/.retro-cloud.env"

echo "TEARDOWN: Run PowerShell scripts to remove the Azure resources"
pwsh -executionpolicy bypass -File ".\teardown-az.ps1" -resourceGroup "$rgPrefix"

echo "TEARDOWN: Done!"
