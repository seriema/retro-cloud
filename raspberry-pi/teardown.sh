#!/bin/bash

# Abort on error, and error if variable is unset
set -eu

echo "TEARDOWN: Run PowerShell scripts to remove the Azure resources"
pwsh -executionpolicy bypass -File ".\teardown-az.ps1"

echo "TEARDOWN: Done!"
