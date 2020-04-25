# Abort on error
$ErrorActionPreference = "Stop"

./install-az-module.ps1

./login-az.ps1

./create-vm.ps1
