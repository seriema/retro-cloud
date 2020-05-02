# Take a parameter for prefixing the Azure resource group name. It default to the current date to be unique
# yet findable. Useful values could be the build number during CI, or the users unique machine name.
param (
    [string]$rgPrefix = [NullString]::Value
)

# Abort on error
$ErrorActionPreference = "Stop"

./install-az-module.ps1

./create-vm.ps1 $rgPrefix
