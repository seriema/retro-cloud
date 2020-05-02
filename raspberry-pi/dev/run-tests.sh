#!/bin/bash

# Abort on error, error if variable is unset, and error if any pipeline element fails
set -euo pipefail

echo "TEST: Verify that ROM shows up in Azure File Share"
pwsh -executionpolicy bypass -File './retro-cloud-setup/dev/test-az-share.ps1'

echo "TEST: Verify scraper output on VM"
bash -i ssh-vm.sh 'bash -i retro-cloud-setup/dev/test-gamelist.sh'

echo "TEST: Done"
