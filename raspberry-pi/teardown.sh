#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

# Disable lint: the .retro-cloud.env file is created by create-vm.ps1 so it can't be included for shellcheck (https://github.com/koalaman/shellcheck/wiki/SC1091)
# shellcheck disable=SC1090
source "$HOME/.retro-cloud.env"

echo "TEARDOWN: Run PowerShell scripts to remove the Azure resources"
pwsh -executionpolicy bypass -File ".\teardown-az.ps1"

echo "TEARDOWN: Done!"
