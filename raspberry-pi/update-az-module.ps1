# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-6#raspbian

# Abort on error
$ErrorActionPreference = "Stop"

###################################
# Update the Azure PowerShell module
Install-Module -Name Az -AllowClobber -Force
